export PATH=$HOME/bin:/usr/local/bin:/usr/local/sbin:/opt/homebrew/bin:$PATH

# User configuration
export MANPATH="/usr/local/man:$MANPATH"
export LANG=en_US.UTF-8

# Compilation flags
export ARCHFLAGS="-arch x86_64"

# SSH 
alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
export dev=$HOME/dev
export SSH_AUTH_SOCK=~/.bitwarden-ssh-agent.sock

# Vim
alias vim='nvim'

# Brew stuff
export PATH="/opt/homebrew/opt/curl/bin:$PATH"
export CPPFLAGS="-I/opt/homebrew/opt/curl/include"

#################################################
# Antidote Stuff

# This is suggesting you have brew

source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh

antidote load

# Set the root name of the plugins files (.txt and .zsh) antidote will use.
zsh_plugins=~/.zsh_plugins

# Ensure the .zsh_plugins.txt file exists so you can add plugins.
[[ -f ${zsh_plugins}.txt ]] || touch ${zsh_plugins}.txt

# Lazy-load antidote from its functions directory.
fpath=(/path/to/antidote/functions $fpath)
autoload -Uz antidote
autoload -Uz compinit && compinit
autoload -Uz promptinit && promptinit

# Generate a new static file whenever .zsh_plugins.txt is updated.
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  antidote bundle <${zsh_plugins}.txt >|${zsh_plugins}.zsh
fi

# Source your static plugins file.
source ${zsh_plugins}.zsh

#################################################

# Geometry
source .geometry/geometry.zsh

GEOMETRY_RPROMPT+=(geometry_exec_time pwd)      # append exec_time and pwd right prompt
GEOMETRY_TITLE=(geometry_node)
GEOMETRY_GIT_TIME_DETAILED=true     # show full time (e.g. `12h 30m 53s`) instead of the coarsest interval (e.g. `12h`)

#################################################

# NVM

export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

export PATH="/opt/homebrew/sbin:$PATH"

#################################################

# KUBERNETES
KUBE_CONFIG=~/.kube/config
alias k='kubectl'
alias dk='kubectl --kubeconfig=/Users/jansenfuller/.kube/config_lab'
