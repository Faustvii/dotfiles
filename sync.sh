#!/bin/bash

# Set your variables
export SSH_ASKPASS=ksshaskpass
LC_TIME="C.UTF-8" # English 24 hour format  
CONFIG_DIR="$HOME/Git/dotfiles"
PUSH_INTERVAL=600 # 10 minutes in seconds 

eval "$(ssh-agent)"
ssh-add

# Function to push changes to the Git repo
push_changes() {
  cd "$CONFIG_DIR" || exit
  git add .
  git commit -m "Automated commit: $(date)"
  git fetch
  git rebase
  git push 
}

# Main loop
while true; do
  # push changes every 10 minutes
  push_changes
  sleep "$PUSH_INTERVAL"
done