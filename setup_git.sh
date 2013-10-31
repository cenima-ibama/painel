#!/usr/bin/sh

NAME=`git config --global user.name`
EMAIL=`git config --global user.email`
USER=`git config --global github.user`

[[ -z $NAME ]] && read -p "Nome: " NAME
[[ -z $EMAIL ]] && read -p "Email: " EMAIL
[[ -z $USER ]] && read -p "Username: " USER

git config --global user.name $NAME
git config --global user.email $EMAIL
git config --global github.user $USER
git config --global color.ui true
git config --global push.default matching
git config --global core.editor "vim"
git config --global --list
ORIGIN=`git remote`
if [[ -z $ORIGIN ]]; then
  read -p "Repository [ex: xoox/nipples]: " REPOSITORY
  git remote add origin https://github.com/${REPOSITORY}
  git pull origin master
  git remote set-url --push origin https://github.com/${REPOSITORY}
else
  read -p "Repository [ex: xoox/nipples]: " REPOSITORY
  git remote set-url --push origin https://github.com/${REPOSITORY}
fi
