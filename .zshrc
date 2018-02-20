export PATH=$HOME/bin:/usr/local/bin:$PATH

source ~/geometry/geometry.zsh
GEOMETRY_PROMPT_PLUGIN=(exec_time git jobs)

export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vi'
else
  export EDITOR='vim'
fi

# Compilation flags
export ARCHFLAGS="-arch x86_64"

# ssh
export SSH_KEY_PATH="~/.ssh/id_rsa"


alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
alias vim='/Applications/MacVim.app/Contents/MacOS/Vim'
export dev=$HOME/sync/dev
