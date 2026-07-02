# dotfiles

GNU Stow dotfiles for Arch Linux + Hyprland. Each top-level directory is a stow package that symlinks into `$HOME` via `.stowrc` (`--dotfiles --target ~`).

## Quick start

```bash
git clone <this-repo> ~/Projects/stowage
cd ~/Projects/stowage
git submodule update --init
stow hyprland waybar mako kitty alacritty zsh tmux git nvim vim ssh gh pass scripts wallpapers
```

## Packages

| Package | What it configures |
|---|---|
| `hyprland/` | Hyprland WM, hyprlock, hypridle, hyprpaper, GTK, XDG portals |
| `waybar/` | Waybar status bar |
| `mako/` | Mako notification daemon |
| `kitty/` | Kitty terminal |
| `alacritty/` | Alacritty terminal |
| `zsh/` | `.zshrc`, spaceship prompt, zsh completions |
| `tmux/` | tmux + TPM plugins |
| `git/` | `.gitconfig` |
| `nvim/` | Neovim (kickstart.nvim submodule) |
| `vim/` | `.vimrc` (legacy) |
| `ssh/` | `~/.ssh/config` |
| `gh/` | GitHub CLI config |
| `pass/` | `~/.password-store/` (GPG-encrypted) |
| `scripts/` | Helper scripts → `~/.local/bin/` |
| `wallpapers/` | Custom wallpapers → `~/Pictures/wallpapers/` |

## Post-stow setup

### Bluetooth

Disable blueman tray icon (Waybar has its own bluetooth module):
```bash
gsettings set org.blueman.general plugin-list "['!StatusNotifierItem', '!StatusIcon']"
mkdir -p ~/.config/autostart
echo -e '[Desktop Entry]\nHidden=true' > ~/.config/autostart/blueman.desktop
```

### kmscon (virtual terminal)

kmscon replaces the kernel's VTs with a KMS/DRM terminal with proper font rendering. Config lives at `/etc/kmscon/kmscon.conf` (not stowed — the system service runs as root).

```bash
sudo pacman -S kmscon
sudo mkdir -p /etc/kmscon
sudo tee /etc/kmscon/kmscon.conf <<'EOF'
font-name=Noto Sans Mono
font-size=14
xkb-layout=us
palette=solarized-dark
hwaccel=true
EOF
sudo ln -s /usr/lib/systemd/system/kmsconvt@.service \
           /etc/systemd/system/autovt@.service
sudo systemctl daemon-reload
```

`hwaccel=true` works on this machine (RX 5700 XT / `amdgpu`).
