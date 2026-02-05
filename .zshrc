# Directories
PATH=$HOME:/opt/homebrew/bin:/opt/homebrew/opt/curl/bin:/usr/local/bin:/usr/local/sbin:$PATH
alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
dev=$HOME/dev

# User configuration
MANPATH="/usr/local/man:$MANPATH"
LANG=en_US.UTF-8
ARCHFLAGS="-arch x86_64"
CPPFLAGS="-I/opt/homebrew/opt/curl/include"

# SSH
SSH_AUTH_SOCK=~/.bitwarden-ssh-agent.sock

# Vim
alias vim='nvim'

# git
alias ga='git add'
alias gc='git commit'
alias gpl='git pull'
alias gpu='gpl | git push'
alias gch='git checkout'
alias gnb='git checkout -b'

# Kubernetes
KUBE_CONFIG=~/.kube/config
alias k='kubectl'

#################################################
# Antidote Stuff

ANTIDOTE_PATH=~/.antidote
source $ANTIDOTE_PATH/antidote.zsh

# Set the root name of the plugins files (.txt and .zsh) antidote will use.
zsh_plugins=~/.zsh_plugins

# Ensure the .zsh_plugins.txt file exists so you can add plugins.
[[ -f ${zsh_plugins}.txt ]] || touch ${zsh_plugins}.txt

# Lazy-load antidote from its functions directory.
fpath=(/path/to/antidote/functions $fpath)
autoload -Uz antidote

# Generate a new static file whenever .zsh_plugins.txt is updated.
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  antidote bundle <${zsh_plugins}.txt >|${zsh_plugins}.zsh
fi

# Source your static plugins file.
source ${zsh_plugins}.zsh

#################################################

# Geometry
GEOMETRY_TITLE=(geometry_node)
GEOMETRY_GIT_TIME_DETAILED=true     # show full time (e.g. `12h 30m 53s`) instead of the coarsest interval (e.g. `12h`)

#################################################

# NVM

NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

PATH="/opt/homebrew/sbin:$PATH"
