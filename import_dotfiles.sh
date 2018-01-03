# Clones in the repo
git clone --bare https://github.com/jansenfuller/dotfiles.git $HOME/.cfg
# Asigns config
function config {
   /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME $@
}
#Backing up config files
mkdir -p .config-backup
if [ $? = 0 ]; then
  echo "Checked out config.";
  else
    echo "Backing up pre-existing dot files.";
    config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}
fi;
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
config fetch --all
config reset --hard master
config checkout
