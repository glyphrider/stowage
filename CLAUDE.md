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
| `hyprland/` | Hyprland WM, hyprlock, hypridle, hyprpaper, GTK, XDG portals | `hyprland` `hyprlock` `hypridle` `hyprpaper` `hyprpolkitagent` `xdg-desktop-portal-hyprland` `xdg-desktop-portal-gtk` `archlinux-wallpaper` `brightnessctl` `playerctl` `wireplumber` `wmenu` `hyprlauncher`(AUR) `ttf-firacode-nerd` |
| `waybar/` | Waybar status bar (active config in `dot-config/waybar/`) | `waybar` `pavucontrol` |
| `mako/` | Mako notification daemon | `mako` `libnotify` |
| `kitty/` | Kitty terminal | `kitty` `ttf-noto-nerd` |
| `alacritty/` | Alacritty terminal | `alacritty` `ttf-firacode-nerd` |
| `zsh/` | `.zshrc`, spaceship prompt config, zsh completions (`dot-zfunc/`) | `zsh` `fzf` `zoxide` `eza` `ksshaskpass` (zinit installs itself on first shell launch) |
| `tmux/` | tmux config + TPM plugins (tpm is a git submodule) | `tmux` |
| `git/` | `.gitconfig` | `git` |
| `vim/` | `.vimrc` | `neovim` (`vim` is aliased to `nvim`) |
| `ssh/` | `~/.ssh/config` | `openssh` |
| `gh/` | GitHub CLI config | `github-cli` |

`dot-config/` at the repo root holds older/inactive configs (sway, wofi, nvim, older hyprland/waybar). The active hyprland config lives in `hyprland/dot-config/hypr/`.

## Hyprland config

The main Hyprland config is `hyprland/dot-config/hypr/hyprland.lua` — a Lua file using the `hl.*` API (Hyprland's native Lua config). Workspaces 1–5 are pinned to DP-1 and 6–10 to DP-2. `SUPER` is the main modifier.

## tmux plugins

TPM (`tpm`) is tracked as a git submodule at `tmux/dot-tmux/plugins/tpm`. After cloning, run:

```bash
git submodule update --init
```

Other plugins (catppuccin, tmux-battery, tmux-cpu, tmux-sensible, tmux-yank, vim-tmux-navigator) are checked in directly under `tmux/dot-tmux/plugins/`.
