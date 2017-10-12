# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to oh-my-zsh .
export ZSH=~/.oh-my-zsh

# Set name of the theme to load. 
ZSH_THEME="fino"
# Interesting themes:
# arrow
# terminalparty
# bureau
# bira
# kolo
# mortalscumbag
# nanotech
# nicoulaj
# pmcgee
# fino/-time

# Uncomment this line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment this line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment this line to disable bi-weekly auto-update.
# DISABLE_AUTO_UPDATE="true"

# Uncomment this line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment this line to disable color in ls.
# DISABLE_LS_COLORS="true"

# Uncomment this line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment this line to enable command correction.
ENABLE_CORRECTION="true"

# Uncomment this line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment this line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment this line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Add custom plugins to ~/.oh-my-zsh/custom/plugins/
# Eg; plugins=(rails git textmate ruby lighthouse)
# Too many plugins slow down shell startup.
plugins=(git git-remote-branch github gitignore gnu-utils gpg-agent pip pylint python sudo vim-interaction zsh_reload)

source $ZSH/oh-my-zsh.sh

# User configuration
# export MANPATH="/usr/local/man:$MANPATH"
# Manually set language environment
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
export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. 
# Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
alias list-aur='sudo pacman -Qqm'
alias list-recent-installed='cat /var/log/pacman.log | grep -i installed'
alias list-all-pacages='sudo pacman -Qqt'
