# Directories
export PATH=$HOME/go/bin:$HOME/.cargo/bin:/opt/homebrew/sbin:/opt/homebrew/bin:/opt/homebrew/opt/curl/bin:/usr/local/bin:/usr/local/sbin:$PATH
alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
export dev=$HOME/dev

# User configuration
export MANPATH="/usr/local/man:$MANPATH"
export LANG=en_US.UTF-8
export ARCHFLAGS="-arch x86_64"
export CPPFLAGS="-I/opt/homebrew/opt/curl/include"
alias wrangler="npx wrangler"
export XDG_CONFIG_HOME="$HOME/.config"
export EDITOR="vim"
alias new-secret="openssl rand -base64 36"

# SSH
export SSH_AUTH_SOCK=~/.bitwarden-ssh-agent.sock

# Curl
function hcurl() { curl --header "Host: $1" ${@:2} ;}

# Vim
alias vim='nvim'

# git
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gpl='git pull'
alias gpu='git push'
alias gch='git checkout'
alias gnb='git checkout -b'
alias forgejo='tea'

# Kubernetes
export KUBE_CONFIG=~/.kube/config
alias k='kubectl'
alias ka='kubectl apply -f'
alias kd='kubectl delete -f'
alias kdf='kubectl delete --force -f'
alias kc='kubectl config use-context'
alias t='talosctl'

#################################################
# Antidote Stuff

export ANTIDOTE_PATH=~/.antidote
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
export GEOMETRY_TITLE=(geometry_node)
export GEOMETRY_GIT_TIME_DETAILED=true     # show full time (e.g. `12h 30m 53s`) instead of the coarsest interval (e.g. `12h`)

#################################################

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

PATH="/Users/jansenfuller/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/Users/jansenfuller/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/Users/jansenfuller/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/Users/jansenfuller/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/Users/jansenfuller/perl5"; export PERL_MM_OPT;
# lean-ctx shell hook — begin
if [ -f "/Users/jansenfuller/.lean-ctx/shell-hook.zsh" ]; then
. "/Users/jansenfuller/.lean-ctx/shell-hook.zsh"
fi
# lean-ctx shell hook — end

# pnpm
export PNPM_HOME="/Users/jansenfuller/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end
