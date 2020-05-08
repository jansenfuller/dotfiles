export PATH=$HOME/bin:/usr/local/bin:$PATH
#-------------------------------------------------------------------------------------------------------------------------
### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zinit-zsh/z-a-patch-dl \
    zinit-zsh/z-a-as-monitor \
    zinit-zsh/z-a-bin-gem-node



### End of Zinit's installer chunk
GEOMETRY_COLOR_DIR=152
PROMPT_GOEMETRY_COLORIZE_SYMBOL=true
GEOMETRY_PROMPT_PLUGINS=(exec_time git)
zinit light geometry-zsh/geometry

zinit ice blockf
zinit light zsh-users/zsh-completions
zinit load zdharma/history-search-multi-word
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light marzocchi/zsh-notify
#-------------------------------------------------------------------------------------------------------------------------


# User configuration
export MANPATH="/usr/local/man:$MANPATH"
export LANG=en_US.UTF-8

# Compilation flags
export ARCHFLAGS="-arch x86_64"

# SSH 
export SSH_KEY_PATH="~/.ssh/id_rsa"

alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
export PATH="/usr/local/sbin:$PATH"
export dev=$HOME/dev
