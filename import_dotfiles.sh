# Makes sure that instalation is in the home directory
cd ~

# Clones in the repo
git clone --bare https://github.com/jansenfuller/dotfiles.git $HOME/.cfg

# Asigns config
function config {
   /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME $@
}

# Backing up config files
mkdir -p .config-backup
if [ $? = 0 ]; then
  echo "Checked out config.";
  else
    echo "Backing up pre-existing dot files.";
    config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}
fi;

# Installs Antidote
git clone --depth=1 https://github.com/mattmc3/antidote.git ~/.antidote
git clone https://github.com/NvChad/starter ~/.config/nvim && nvim

# Resets anything that might have been changed
config fetch --all
config reset --hard master
config checkout
