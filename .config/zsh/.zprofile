#!/bin/sh
# ~/.config/zsh/.zprofile
# env vars set on login — zsh settings in ~/.config/zsh/.zshrc
# ~/.zshenv must contain: export ZDOTDIR="$HOME/.config/zsh"

# ── Default programs ──────────────────────────────────────────────
export EDITOR="code --wait"
export VISUAL="code --wait"
export TERMINAL="kitty"
export BROWSER="librewolf"
export PAGER="less"

# ── XDG Base Directories ──────────────────────────────────────────
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# ── Zsh XDG bootstrap ─────────────────────────────────────────────
#export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# ── History files ─────────────────────────────────────────────────
export LESSHISTFILE="$XDG_CACHE_HOME/less_history"
export PYTHON_HISTORY="$XDG_DATA_HOME/python/history"
export NODE_REPL_HISTORY="$XDG_STATE_HOME/node_repl_history"

# ── X11 ───────────────────────────────────────────────────────────
export XINITRC="$XDG_CONFIG_HOME/x11/xinitrc"
export XPROFILE="$XDG_CONFIG_HOME/x11/xprofile"
export XRESOURCES="$XDG_CONFIG_HOME/x11/xresources"

# ── Tool config overrides (XDG compliance) ───────────────────────
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc-2.0"
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export GOPATH="$XDG_DATA_HOME/go"
export GOBIN="$GOPATH/bin"
export GOMODCACHE="$XDG_CACHE_HOME/go/mod"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export KUBECONFIG="$XDG_CONFIG_HOME/kube/config"
export TALOSCONFIG="$XDG_CONFIG_HOME/talos/config"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"
export NUGET_PACKAGES="$XDG_CACHE_HOME/NuGetPackages"
export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME/java"
export _JAVA_AWT_WM_NONREPARENTING=1
export PARALLEL_HOME="$XDG_CONFIG_HOME/parallel"
export FFMPEG_DATADIR="$XDG_CONFIG_HOME/ffmpeg"
export WINEPREFIX="$XDG_DATA_HOME/wineprefixes/default"

# ── fzf ───────────────────────────────────────────────────────────
export FZF_DEFAULT_OPTS="--style minimal --color 16 --layout=reverse --height 30% --preview='bat -p --color=always {}'"
export FZF_CTRL_R_OPTS="--style minimal --color 16 --info inline --no-sort --no-preview"

# ── Colored man pages & less ──────────────────────────────────────
export MANPAGER="less -R --use-color -Dd+r -Du+b"
export LESS="R --use-color -Dd+r -Du+b"
export LESS_TERMCAP_mb="$(printf '%b' '[1;31m')"
export LESS_TERMCAP_md="$(printf '%b' '[1;36m')"
export LESS_TERMCAP_me="$(printf '%b' '[0m')"
export LESS_TERMCAP_so="$(printf '%b' '[01;44;33m')"
export LESS_TERMCAP_se="$(printf '%b' '[0m')"
export LESS_TERMCAP_us="$(printf '%b' '[1;32m')"
export LESS_TERMCAP_ue="$(printf '%b' '[0m')"

# ── PATH ──────────────────────────────────────────────────────────
export PATH="\
$XDG_CONFIG_HOME/scripts:\
$HOME/.local/bin:\
$XDG_DATA_HOME/cargo/bin:\
$GOBIN:\
$PATH"

# ── SSH Agent (keychain) ──────────────────────────────────────────
if command -v keychain >/dev/null 2>&1; then
  KEYCHAIN_DIR="$XDG_STATE_HOME/keychain"
  [ -d "$KEYCHAIN_DIR" ] || mkdir -p "$KEYCHAIN_DIR"
  eval "$(keychain --eval --quiet --noask --timeout 480 --dir "$KEYCHAIN_DIR" id_ed25519 2>/dev/null)"
fi