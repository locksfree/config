#!/bin/bash

# Setup the vim configuration
if [ ! -d ~/configurations/ ]
then
	mkdir -p ~/configurations > /dev/null 2>&1
	cd ~/configurations
	echo "Retrieving configurations..."
	git clone https://github.com/locksfree/dotfiles.git # > /dev/null 2>&1

	echo "Configuring vim..."
	[ -f "~/.vimrc" ] && mv ~/.vimrc ~/.vimrc.bak
	ln -s ~/configurations/dotfiles/vim/vimrc.vim ~/.vimrc
	mkdir -p ~/.vim/bundle
	ln -s ~/configurations/dotfiles/vim/vundles ~/.vim/vundles
	
	echo "Configuring terminator..."
	mkdir -p ~/.config/terminator
	ln -s ~/configurations/dotfiles/terminator/config ~/.config/terminator/config

	echo "Vim will now be run to install the plugins. Close it once done"
	read -p "Press any key to start..."
	vim
else
	cd ~/configurations/dotfiles
	echo "Updating the configurations..."
	git pull origin master > /dev/null 2>&1
fi

# Configuring git
if [ ! -L ~/.gitconfig  ]
then
   if [ -f ~/.gitconfig ]
   then
      echo "~/.gitconfig is a regular file, you may want to change it to point to your dotfiles git config"
   else
      echo "Linking ~/.gitconfig to your dotfiles..."
      ln -s ~/configurations/dotfiles/git/config ~/.gitconfig
   fi
else
   if [ ! -e ~/.gitconfig ]
   then
      echo "Fixing broken ~/.gitconfig symlink, pointing to a non-existent file"
      echo -e "\tOld target: $(readlink ~/.gitconfig)"
      rm ~/.gitconfig
      ln -s ~/configurations/dotfiles/git/config ~/.gitconfig
      echo -e "\tNew target: $(readlink ~/.gitconfig)"
   else
      # Let's check where the link points to
      if [ "$(readlink ~/.gitconfig)" = "$HOME/configurations/dotfiles/git/config" ]
      then
         echo "Valid ~/.gitconfig symlink, not changing anything"
      else
         echo "Valid ~/.gitconfig symlink, but not pointing at your dotfiles git config, you may want to change it"
      fi
   fi
fi

# Change the default mapping of tasklist
if [ `cat ~/.vim/bundle/TaskList.vim/plugin/tasklist.vim | head -n 369 | tail -n 1 | grep '<Leader>t' | wc -l` -ne 0 ]
then
   echo "Changing mapping of tasklist"
   cat ~/.vim/bundle/TaskList.vim/plugin/tasklist.vim | sed -E 's/map <unique> <Leader>t <Plug>TaskList/map <unique> <Leader>n <Plug>TaskList/g' > /tmp/tasklist.vim
   mv /tmp/tasklist.vim ~/.vim/bundle/TaskList.vim/plugin/tasklist.vim
fi

# Create ~/.vim/view and ~/.vim/tmp if not there
mkdir -p ~/.vim/view
mkdir -p ~/.vim/tmp

# Install the Source Code Pro font
if [ ! -d ~/.fonts/scp ]
then
   echo "Downloading source code pro..."
   mkdir -p ~/.fonts/scp
   git clone https://github.com/adobe-fonts/source-code-pro.git ~/.fonts/scp > /dev/null
   echo "Requires sudo to refresh the font-cache"
   fc-cache -vf ~/.fonts/ > /dev/null 
fi

# Install powerline fonts
if [ ! -f ~/.fonts/PowerlineSymbols.otf ]
then
   echo "Downloading powerline fonts..."
   wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf > /dev/null 2>&1
   wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf > /dev/null 2>&1
   mv PowerlineSymbols.otf ~/.fonts/
   fc-cache -vf ~/.fonts/ > /dev/null
   mkdir -p ~/.config/fontconfig/conf.d
   mv 10-powerline-symbols.conf ~/.config/fontconfig/conf.d/
fi

if [ ! -f ~/.fonts/Hasklig-Regular.otf ]
then
   wget https://github.com/i-tu/Hasklig/raw/master/target/Hasklig-Regular.otf > /dev/null
   mv Hasklig-Regular.otf ~/.fonts/
   fc-cache -vf ~/.fonts/ > /dev/null
   # Set the font in the terminator config
fi

if [ ! -d ~/.oh-my-zsh ]
then
   echo "Installing oh-my-zsh..."
   sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
fi

# Load nvm by default
if [ `cat ~/.zshrc | grep nvm.sh | wc -l` -eq 0 ]
then
   echo -e "\n#Load nvm\nsource ~/.nvm/nvm.sh" >> ~/.zshrc
fi

# Setup meld as the git merge tool of choice
if [ `cat ~/.gitconfig | grep mymeld | wc -l` -eq 0 ]
then
   echo "[merge]" >> ~/.gitconfig
   echo "tool = mymeld\nconflictstyle = diff3" >> ~/.gitconfig
   echo '[mergetool "mymeld"]' >> ~/.gitconfig
   echo 'cmd = meld --diff $BASE $LOCAL --diff $BASE $REMOTE --diff $LOCAL $BASE $REMOTE --output $MERGED' >> ~/.gitconfig
fi

if [ ! -d ~/.nvm ]
then
   echo "Installing nvm..."
   git clone https://github.com/creationix/nvm.git ~/.nvm > /dev/null
   cd ~/.nvm
   git checkout `git describe --abbrev=0 --tags` > /dev/null

   if [ `cat ~/.bashrc | grep 'nvm/nvm.sh' | wc -l` -eq 0 ]
   then
      echo "Adding nvm to your bashrc"
      echo -e "\n#Add nvm support\n. ~/.nvm/nvm.sh" >> ~/.bashrc
   fi

   echo "Please source ~/.nvm/nvm.sh or restart your console"
fi
