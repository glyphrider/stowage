# Setup ZINIT
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [ ! -d "$ZINIT_HOME" ]; then
	mkdir -p "$(dirname $ZINIT_HOME)"
	git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# Plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::command-not-found

zstyle :omz:plugins:ssh-agent helper ksshaskpass
zstyle :omz:plugins:ssh-agent agent-forwarding yes
zstyle :omz:plugins:ssh-agent identities id_rsa id_rsa2048 id_ed25519 id_ed25519_sk
zstyle :omz:plugins:eza dirs-first yes
zstyle :omz:plugins:eza git-status yes
zstyle :omz:plugins:eza show-group yes

zinit snippet OMZP::ssh-agent

autoload -U compinit && compinit

zinit cdreplay -q

# Key Bindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion Styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
zstyle ':omz:plugins:ssh-agent' helper ksshaskpass

# Aliases
alias ls='eza --color=auto --icons --git'
alias stow="stow -t $HOME --dotfiles" #  --no-folding"
alias vim="nvim"

# Shell Integrations
#eval "$(oh-my-posh init zsh --config 'https://raw.githubusercontent.com/dreamsofautonomy/zen-omp/main/zen.toml')"
eval "$(oh-my-posh init zsh --config 'https://github.com/JanDeDobbeleer/oh-my-posh/blob/main/themes/avit.omp.json')"
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"
export GPG_TTY=$TTY

# Path
typeset -U PATH path
[ ! -d "$HOME/.local/bin" ] || path=("$HOME/.local/bin" $path)
[ ! -d "$HOME/.cargo/bin" ] || path+=("$HOME/.cargo/bin")
fpath+=~/.zfunc

