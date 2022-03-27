#!/bin/bash 
set -xe 
# Tmux stuff and other cool stuff
# https://www.2daygeek.com/powerline-adds-powerful-statusline-to-vim-bash-tumx-in-ubuntu-fedora-debian-arch-linux-mint/


echo "configureing powerline"
sudo pip3 install powerline-status

sudo tee -a .bashrc > /dev/null <<EOT
if [ -f `which powerline-daemon` ]; then
  powerline-daemon -q
  POWERLINE_BASH_CONTINUATION=1
  POWERLINE_BASH_SELECT=1
  . /usr/local/lib/python3.6/site-packages/powerline/bindings/bash/powerline.sh
fi
EOT


echo "configuring tmux"
git clone --recursive https://github.com/tony/tmux-config.git ~/.tmux
ln -s ~/.tmux/.tmux.conf ~/.tmux.conf
echo "source \"/usr/local/lib/python3.6/site-packages/powerline/bindings/tmux/powerline.conf"\" >> ~/.tmux.conf
echo "set -g mouse on"  >> ~/.tmux.conf

sudo dnf install ncurses-devel curl -y
curl 'https://vim-bootstrap.com/generate.vim' --data 'editor=vim&langs=javascript&langs=go&langs=html&langs=ruby&langs=python' > ~/.vimrc