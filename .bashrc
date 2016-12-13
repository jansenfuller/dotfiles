# Source custom local shell scripts
if [ -f ~/.bashrc_local.sh ]; then
	source ~/.bashrc_local.sh;
fi

if [ -f ~/.aliases.sh ]; then
	source ~/.aliases.sh;
fi

if [ -f ~/.aliases ]; then
	source ~/.aliases;
fi

alias config='git --git-dir=~/.cfg/ --work-tree=~'
export PATH
