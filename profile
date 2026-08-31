#!/bin/sh
PS1='\W$ '
cd "$HOME" || exit 1
clear
echo "************************************************************************"
echo "* PolyBandit: Linux command-line practice                              *"
echo "* Read README.txt, solve the level, and save the case-sensitive answer.*"
echo "* Move between levels with nextlevel and prevlevel.                    *"
echo "************************************************************************"
cat README.txt
