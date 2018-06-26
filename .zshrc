export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=/Users/jansenfuller/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
ZSH_THEME="geometry/geometry"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
HIST_STAMPS="mm/dd/yyyy"

plugins=(
  git,
  history,
)
GEOMETRY_PROMPT_PLUGIN=(exec_time git jobs)

source $ZSH/oh-my-zsh.sh

# User configuration

export MANPATH="/usr/local/man:$MANPATH"
export LANG=en_US.UTF-8

# Compilation flags
export ARCHFLAGS="-arch x86_64"

# ssh
export SSH_KEY_PATH="~/.ssh/id_rsa"

alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
alias vim='/Applications/MacVim.app/Contents/MacOS/Vim'
export PATH="/Applications/CMake.app/Contents/bin":"$PATH"
export dev=$HOME/sync/dev
