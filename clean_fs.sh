echo "\n---Updating/upgrading all packages---"
pacaur -Syu
echo "---Double-checking all packages are up to date---"
pacaur -Syu

echo "---Removing orphaned or left over packages---"
sudo pacman -Rns $(pacman -Qttdq)
echo "---Finding and deleting broken or missing symlinks---"
find -xtype l -print0 --null | xargs rm
echo "---Removing undesirable folders/files---"
wget -qO- https://gist.githubusercontent.com/jansenfuller/f7a7029dfe2995ed0ad106c290241daf/raw/df9c2b529865b3b85fad9803d056388324350fb6/clean_fs.py | sudo python -

echo "---Cleaning package cache---"
sudo pacman -Sc
sudo paccache -rk 2

echo "---Here are all the files not owned by packages (WARNING: This will include files created by users):---"
find /etc /opt /usr | sort &> all_files.txt
sudo pacman -Qlq | sed 's|/$||' | sort &> owned_files.txt
#comm -23 all_files.txt owned_files.txt

echo "---Removing temp files---"
rm ./all_files.txt ./owned_files.txt
