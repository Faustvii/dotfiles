export ZDOTDIR="$HOME/.config/zsh"

# XDG Base Directories — needed by .zshrc regardless of login-shell status
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# mise shims — static PATH entry so tool versions resolve in non-interactive/
# non-login shells too (AI tools, editors, scripts), where `mise activate` never runs
export PATH="$XDG_DATA_HOME/mise/shims:$PATH"