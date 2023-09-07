#!/bin/bash

# Set your variables
LC_TIME="C.UTF-8" # English 24 hour format
CONFIG_DIR="$HOME/Git/dotfiles"
PUSH_INTERVAL=600 # 10 minutes in seconds

# Function to push changes to the Git repo
push_changes() {
  cd "$CONFIG_DIR"
  git add .
  git commit -m "Automated commit: $(date)"
  git fetch
  git rebase
  git push 
}

# Main loop
while true; do
  # Monitor the folder for changes and push changes every 10 minutes
  inotifywait -r --exclude '/\.git/' -e modify,create,delete,moved_to,moved_from --timeout "$PUSH_INTERVAL" "$CONFIG_DIR"
  push_changes
done