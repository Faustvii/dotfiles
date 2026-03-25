# ~/.config/zsh/aliases.zsh
# shell-agnostic aliases live in ~/.config/shell/alias

# ── Better defaults ───────────────────────────────────────────────
alias ls='eza --group-directories-first'
alias ll='eza -lh --group-directories-first --git'
alias la='eza -lah --group-directories-first --git'
alias tree='eza --tree'
alias cat='bat --paging=never'
alias grep='grep --color=auto'
alias diff='diff --color=auto'

# ── System ────────────────────────────────────────────────────────
alias sysup='sudo pacman -Syu'
alias orphans='sudo pacman -Rns $(pacman -Qtdq)'
alias psc='ps aux | grep -v grep | grep'
alias myip='curl -s ifconfig.me'
alias ports='ss -tulnp'