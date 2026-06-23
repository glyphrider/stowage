#!/usr/bin/env python3
"""
Hyprland IPC proxy — translates old-style dispatch commands to the Lua
format required by Hyprland 0.55+.

  old: dispatch workspace 3
  new: dispatch hl.dsp.focus({ workspace = 3 })
"""
import asyncio, os, re, sys

TRANSLATIONS = [
    (re.compile(r'^dispatch workspace (\S+)$'),
     lambda m: f'dispatch hl.dsp.focus({{ workspace = {m.group(1)} }})'),
    (re.compile(r'^dispatch focusworkspaceoncurrentmonitor (\S+)$'),
     lambda m: f'dispatch hl.dsp.focus({{ workspace = {m.group(1)} }})'),
    (re.compile(r'^dispatch movetoworkspace (\S+)$'),
     lambda m: f'dispatch hl.dsp.window.move({{ workspace = {m.group(1)} }})'),
]

def translate(data: bytes) -> bytes:
    cmd = data.decode(errors='replace').strip()
    for pattern, transform in TRANSLATIONS:
        m = pattern.match(cmd)
        if m:
            return transform(m).encode()
    return data

async def handle_cmd(real_cmd, reader, writer):
    try:
        data = await reader.read(65536)
        r, w = await asyncio.open_unix_connection(real_cmd)
        w.write(translate(data))
        await w.drain()
        resp = await r.read(65536)
        writer.write(resp)
        await writer.drain()
        w.close()
    except Exception:
        pass
    finally:
        writer.close()

async def handle_evt(real_evt, reader, writer):
    try:
        r, w = await asyncio.open_unix_connection(real_evt)
        while True:
            data = await r.read(65536)
            if not data:
                break
            writer.write(data)
            await writer.drain()
    except Exception:
        pass
    finally:
        writer.close()

async def main():
    uid      = os.getuid()
    real_sig = os.environ['HYPRLAND_INSTANCE_SIGNATURE']
    proxy_sig = real_sig + '-proxy'
    real_base  = f'/run/user/{uid}/hypr/{real_sig}'
    proxy_base = f'/run/user/{uid}/hypr/{proxy_sig}'

    real_cmd  = f'{real_base}/.socket.sock'
    real_evt  = f'{real_base}/.socket2.sock'
    proxy_cmd = f'{proxy_base}/.socket.sock'
    proxy_evt = f'{proxy_base}/.socket2.sock'

    os.makedirs(proxy_base, exist_ok=True)
    for p in [proxy_cmd, proxy_evt]:
        try:
            os.unlink(p)
        except OSError:
            pass

    cmd_srv = await asyncio.start_unix_server(
        lambda r, w: handle_cmd(real_cmd, r, w), proxy_cmd)
    evt_srv = await asyncio.start_unix_server(
        lambda r, w: handle_evt(real_evt, r, w), proxy_evt)

    print(f'hypr-ipc-proxy: ready ({proxy_sig})', file=sys.stderr, flush=True)

    async with cmd_srv, evt_srv:
        await asyncio.gather(cmd_srv.serve_forever(), evt_srv.serve_forever())

asyncio.run(main())
