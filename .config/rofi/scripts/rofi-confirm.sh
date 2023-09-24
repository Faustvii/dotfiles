#!/usr/bin/env bash
# Original https://github.com/ntcarlson/dotfiles/blob/delta/config/rofi/scripts/rofi-confirm.sh
ICON="$1"

CANCEL=""
CONFIRM=""

case "$(echo -e "$CANCEL\n$CONFIRM" | rofi -dmenu -theme options-menu -mesg "$ICON" )" in
    "$CANCEL")  exit 1;;
    "$CONFIRM") exit 0;;
esac

exit 1
