# ~/.config/zsh/.zshrc

# ── Modules ───────────────────────────────────────────────────────
zmodload zsh/complist
autoload -Uz compinit && compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
autoload -U colors && colors

# ── Completion ────────────────────────────────────────────────────
zstyle ':completion:*' menu select
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} ma=0\;33
zstyle ':completion:*' squeeze-slashes false
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ── Options ───────────────────────────────────────────────────────
setopt AUTO_MENU MENU_COMPLETE
setopt AUTOCD
setopt AUTO_PARAM_SLASH
setopt NO_CASE_GLOB NO_CASE_MATCH
setopt GLOBDOTS
setopt EXTENDED_GLOB
setopt INTERACTIVE_COMMENTS
unsetopt PROMPT_SP
stty stop undef

# ── History ───────────────────────────────────────────────────────
HISTSIZE=1000000
SAVEHIST=1000000
HISTFILE="$XDG_STATE_HOME/zsh/history"
[[ -d "$XDG_STATE_HOME/zsh" ]] || mkdir -p "$XDG_STATE_HOME/zsh"

setopt APPEND_HISTORY INC_APPEND_HISTORY SHARE_HISTORY
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE EXTENDED_HISTORY

# ── Plugins (system) ─────────────────────────────────────────────
# pacman/yay -S zsh-autosuggestions zsh-syntax-highlighting
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ── fzf ───────────────────────────────────────────────────────────
source <(fzf --zsh)

# ── zoxide ────────────────────────────────────────────────────────
eval "$(zoxide init zsh)"

# ── Keybindings ───────────────────────────────────────────────────
bindkey -e
bindkey "^a" beginning-of-line
bindkey "^e" end-of-line
bindkey "^k" kill-line
bindkey "^H" backward-kill-word
bindkey "^J" history-search-forward
bindkey "^K" history-search-backward
bindkey '^R'  fzf-history-widget
bindkey '^[[A' history-search-backward   # up arrow
bindkey '^[[B' history-search-forward    # down arrow

# ── Shell-agnostic aliases & vars ────────────────────────────────
[[ -f "$XDG_CONFIG_HOME/shell/alias" ]] && source "$XDG_CONFIG_HOME/shell/alias"
[[ -f "$XDG_CONFIG_HOME/shell/vars"  ]] && source "$XDG_CONFIG_HOME/shell/vars"

# ── Prompt ────────────────────────────────────────────────────────
eval "$(starship init zsh)"