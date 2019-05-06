export PATH=$HOME/bin:/usr/local/bin:$PATH
# ----------------------------------------
### Added by Zplugin's installer
source '/Users/jansenfuller/.zplugin/bin/zplugin.zsh'
autoload -Uz _zplugin
(( ${+_comps} )) && _comps[zplugin]=_zplugin
### End of Zplugin's installer chunk

GEOMETRY_COLOR_DIR=152
PROMPT_GOEMETRY_COLORIZE_SYMBOL=true
GEOMETRY_PROMPT_PLUGINS=(exec_time git)
zplugin light geometry-zsh/geometry

zplugin ice wait'1' atload'_zsh_autosuggest_start'
zplugin light zsh-users/zsh-autosuggestions
zplugin ice wait"0" atinit"zpcompinit; zpcdreplay"
zplugin light zdharma/fast-syntax-highlighting
zplugin light marzocchi/zsh-notify
# ---------------------------------------

# User configuration
export MANPATH="/usr/local/man:$MANPATH"
export LANG=en_US.UTF-8

# Compilation flags
export ARCHFLAGS="-arch x86_64"

# ssh
export SSH_KEY_PATH="~/.ssh/id_rsa"

alias vim='/Applications/MacVim.app/Contents/MacOS/Vim'
alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
export PATH="/Applications/CMake.app/Contents/bin":"$PATH"
export PATH="/usr/local/sbin:$PATH"
export dev=$HOME/dev
