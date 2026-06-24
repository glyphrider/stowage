# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A GNU Stow dotfiles repository. Each top-level directory is a **stow package** — running `stow <package>` symlinks its contents into `$HOME`. The `.stowrc` sets `--dotfiles --target ~` globally, so this never needs to be specified manually.

## Stow commands

```bash
# Symlink a package into $HOME
stow <package>

# Remove symlinks for a package
stow -D <package>

# Restow (remove then re-add; useful after adding files)
stow -R <package>

# Preview what would be linked without doing it
stow -n -v <package>
```

## The `--dotfiles` convention

Files and directories named `dot-*` are symlinked with the `dot-` prefix replaced by `.`. For example:
- `zsh/dot-zshrc` → `~/.zshrc`
- `hyprland/dot-config/hypr/` → `~/.config/hypr/`
- `tmux/dot-tmux.conf` → `~/.tmux.conf`

## Package structure

| Package | What it configures | Arch packages |
|---|---|---|
| `hyprland/` | Hyprland WM, hyprlock, hypridle, hyprpaper, GTK, XDG portals | `hyprland` `hyprlock` `hypridle` `hyprpaper` `hyprpolkitagent` `xdg-desktop-portal` `xdg-desktop-portal-hyprland` `xdg-desktop-portal-gtk` `archlinux-wallpaper` `brightnessctl` `playerctl` `wireplumber` `wmenu` `ttf-noto-nerd` `hyprlauncher`(AUR) |
| `waybar/` | Waybar status bar (active config in `dot-config/waybar/`) | `waybar` `pavucontrol` `blueman` `grim` `ttf-noto-nerd` |
| `mako/` | Mako notification daemon | `mako` `libnotify` |
| `kitty/` | Kitty terminal | `kitty` `ttf-noto-nerd` |
| `alacritty/` | Alacritty terminal | `alacritty` `ttf-firacode-nerd` |
| `zsh/` | `.zshrc`, spaceship prompt config, zsh completions (`dot-zfunc/`) | `zsh` `fzf` `zoxide` `eza` `ksshaskpass` (zinit installs itself on first shell launch) |
| `tmux/` | tmux config + TPM plugins (tpm is a git submodule) | `tmux` |
| `git/` | `.gitconfig` | `git` |
| `nvim/` | Neovim config via submodule (`glyphrider/kickstart.nvim`) | `neovim` |
| `vim/` | `.vimrc` (legacy) | `vim` |
| `ssh/` | `~/.ssh/config` | `openssh` |
| `gh/` | GitHub CLI config | `github-cli` |
| `pass/` | `pass` password store (`~/.password-store/`) with GPG-encrypted keys | `pass` `gnupg` |
| `scripts/` | Helper scripts in `~/.local/bin/` | `python` |
| `wallpapers/` | Custom wallpapers in `~/Pictures/wallpapers/` | `imagemagick` |

`dot-config/` at the repo root holds older/inactive configs (sway, wofi, nvim, older hyprland/waybar). The active hyprland config lives in `hyprland/dot-config/hypr/`.

## Post-install configuration (not managed by stow)

Some system state lives outside stow and must be set manually after a fresh install.

### Stow all packages

After cloning, stow each package. Most map to `~/.config/` automatically; `scripts` maps to `~/.local/bin/`:

```bash
stow hyprland waybar mako kitty alacritty zsh tmux git nvim vim ssh gh pass scripts wallpapers
```

### Bluetooth / blueman

`blueman` is installed for device pairing via `blueman-manager`. Waybar has a built-in bluetooth module, so the blueman tray icon is disabled to avoid duplication.

Disable tray icon plugins:
```bash
gsettings set org.blueman.general plugin-list "['!StatusNotifierItem', '!StatusIcon']"
```

Suppress XDG autostart for the applet (the applet still runs via D-Bus for the manager):
```bash
mkdir -p ~/.config/autostart
echo -e '[Desktop Entry]\nHidden=true' > ~/.config/autostart/blueman.desktop
```

The Waybar bluetooth module (`on-click = blueman-manager`) is the primary UI. Click it to open the pairing manager.

## Waybar config

Config lives in `waybar/dot-config/waybar/config` (JSON) and `style.css`.
The bar sits at the top of DP-1 only (`"layer": "top"`, `"position": "top"`).

| Position | Module | Notes |
|---|---|---|
| Left | `hyprland/workspaces` | Shows workspace IDs; click to switch (requires IPC proxy — see below) |
| Center | `custom/clock` | `date` exec, updates every 10 s |
| Right | `tray` | System tray |
| Right | `bluetooth` | Click opens `blueman-manager`; tray icon disabled separately |
| Right | `pulseaudio` | Click toggles mute; scroll adjusts volume ±5% |
| Right | `network` | Ethernet/Wi-Fi/disconnected icons |
| Right | `battery` | Hidden on desktop (no batteries warning is expected) |

## Waybar workspace clicking — Hyprland IPC proxy

Hyprland 0.55+ changed its IPC dispatch format to Lua expressions, breaking
waybar's native workspace button clicks. A socket proxy works around this:

- `scripts/dot-local/bin/hypr-ipc-proxy.py` — asyncio daemon that proxies the
  Hyprland IPC socket, translating old-style dispatch commands to new Lua format
  (e.g. `dispatch workspace 3` → `dispatch hl.dsp.focus({ workspace = 3 })`)
- `scripts/dot-local/bin/waybar-hypr` — wrapper that starts the proxy then
  launches waybar with `HYPRLAND_INSTANCE_SIGNATURE` pointing at the proxy
- `hyprland.lua` uses `waybar-hypr` instead of `waybar` so this is automatic

**Removing the proxy when no longer needed** (e.g. after waybar is updated to
send the new Lua format natively):

```bash
# 1. Revert hyprland.lua to launch waybar directly
#    Change: hl.exec_cmd("waybar-hypr")
#    Back to: hl.exec_cmd("waybar")

# 2. Remove the scripts package
stow -D scripts
rm -rf scripts/

# 3. Restart waybar normally
pkill waybar && waybar &
```

## Hyprland config

The main config is `hyprland/dot-config/hypr/hyprland.lua` — Lua using the `hl.*` API.

**Monitors:** DP-1 is primary (2560×1440@144 Hz), DP-2 is secondary. Workspaces 1–5 are pinned to DP-1, 6–10 to DP-2.

**Auto-started on `hyprland.start`:**
- `dbus-update-activation-environment` — propagates Wayland/XDG env to systemd
- `systemctl --user start hyprpolkitagent` — polkit authentication agent
- `/usr/lib/xdg-desktop-portal-gtk` and `xdg-desktop-portal` — portals
- `hyprpaper`, `hypridle`, `mako`, `waybar-hypr`

**Key variables:** terminal = kitty+zsh, menu = wmenu-run, launcher = hyprlauncher. GTK theme is Adwaita:dark.

**Gestures:** 3-finger horizontal swipe switches workspaces.

**Key bindings (SUPER = mod key):**

| Binding | Action |
|---|---|
| `SUPER+Return` | Open terminal (kitty) |
| `SUPER+D` | wmenu-run launcher |
| `SUPER+R` | hyprlauncher |
| `SUPER+Q` | Close window |
| `SUPER+V` | Toggle float |
| `SUPER+X` | Lock screen (hyprlock) |
| `SUPER+1–10` | Switch to workspace |
| `SUPER+SHIFT+1–10` | Move window to workspace |
| `SUPER+S` | Toggle special workspace (scratchpad) |
| `SUPER+arrows` | Focus direction |
| `SUPER+mouse drag` | Move window |
| `SUPER+mouse_down/up` | Scroll workspaces |

## hyprpaper config

Config: `hyprland/dot-config/hypr/hyprpaper.conf`. Wallpapers are set per-monitor:

| Monitor | Wallpaper |
|---|---|
| DP-1 | `simple.png` (dark charcoal, Arch Linux logo in blue) from `archlinux-wallpaper` |
| DP-2 | `~/Pictures/wallpapers/wallpaper_msi_dark.png` (custom, see below) |

All arch wallpapers from `/usr/share/backgrounds/archlinux/` are preloaded so switching is instant. To change a wallpaper, update the relevant `wallpaper { monitor = ..., path = ... }` block.

### Custom wallpapers (`wallpapers/` package)

Stows to `~/Pictures/wallpapers/`. Add new wallpapers here and preload them in `hyprpaper.conf`.

| File | Source | Notes |
|---|---|---|
| `wallpaper_msi_dark.png` | https://storage-asset.msi.com/global/picture/wallpaper/wallpaper_15783783195e14244fac940.jpg | Blue monochrome, darkened for use behind semi-transparent windows |

The dark variant was generated with ImageMagick from the original JPEG:

```bash
magick wallpaper_15783783195e14244fac940.jpg \
  -colorspace Gray \
  -colorspace sRGB \
  -channel R -evaluate multiply 0.03 \
  -channel G -evaluate multiply 0.08 \
  -channel B -evaluate multiply 0.55 \
  +channel \
  wallpaper_msi_dark.png
```

This converts to grayscale for luminance, then suppresses R and G channels to produce shades-of-blue-only output. Output is PNG (lossless) to avoid JPEG compression artifacts in dark areas.

## hypridle config

Config: `hyprland/dot-config/hypr/hypridle.conf`. Idle behavior:

| Timeout | Action |
|---|---|
| 2.5 min | Dim backlight to minimum (brightness saved/restored with `brightnessctl -s/-r`) |
| 5 min | Lock screen (`loginctl lock-session` → hyprlock) |
| 5.5 min | Turn displays off (`hyprctl dispatch dpms off`) |
| Sleep | Lock before suspend; restore DPMS on wake |

## hyprlock config

Config: `hyprland/dot-config/hypr/hyprlock.conf`. Font is **Noto Sans** (`ttf-noto-nerd`, shared with kitty). Background is a blurred screenshot (3 passes).

Colors match the `simple.png` wallpaper palette (Arch Linux blues):
- Input field border: `#228DC1` → `#197098` gradient
- Check state: `#197098` → `#1E4C5F`
- Fail state: red gradient (semantic)

Layout: time (90pt) and date (25pt) top-right with a small inset from the edge; input field centered.

## tmux plugins

Two submodules require initialization after cloning:

```bash
git submodule update --init
```

| Submodule path | What it is |
|---|---|
| `tmux/dot-tmux/plugins/tpm` | Tmux Plugin Manager |
| `nvim/dot-config/nvim` | `glyphrider/kickstart.nvim` — full neovim config |

Other tmux plugins (catppuccin, tmux-battery, tmux-cpu, tmux-sensible, tmux-yank, vim-tmux-navigator) are checked in directly under `tmux/dot-tmux/plugins/`.
