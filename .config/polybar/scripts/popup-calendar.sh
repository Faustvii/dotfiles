#!/bin/sh

BAR_HEIGHT=23  # polybar height
BORDER_SIZE=15  # border size from your wm settings
YAD_WIDTH=222  # 222 is minimum possible value
YAD_HEIGHT=193 # 193 is minimum possible value
DATE="$(date +"%d-%m-%Y")"

case "$1" in
--popup)
    if [ "$(xdotool getwindowfocus getwindowname)" = "yad-calendar" ]; then
        exit 0
    fi

    eval "$(xdotool getmouselocation --shell)" # X and Y are global coordinates

    # Get the total virtual desktop width and height
    TOTAL_GEOM=$(xrandr --query | grep -o 'current [0-9]\+ x [0-9]\+' | awk '{print $2, $4}')
    read -r TOTAL_WIDTH TOTAL_HEIGHT <<< "$TOTAL_GEOM"

    # Fallback if parsing fails (shouldn't happen if xrandr is present)
    if [ -z "$TOTAL_WIDTH" ] || [ -z "$TOTAL_HEIGHT" ]; then
        eval "$(xdotool getdisplaygeometry --shell)" # Fallback to primary screen geometry
        TOTAL_WIDTH="$WIDTH"
        TOTAL_HEIGHT="$HEIGHT"
    fi

    # X position calculation
    # We want to center yad around X, but ensure it doesn't go outside TOTAL_WIDTH
    HALF_YAD_WIDTH=$((YAD_WIDTH / 2))
    PROPOSED_POS_X=$((X - HALF_YAD_WIDTH))

    # Check for left boundary
    if [ "$PROPOSED_POS_X" -lt "$BORDER_SIZE" ]; then
        pos_x=$BORDER_SIZE
    # Check for right boundary: ensure right edge of yad (PROPOSED_POS_X + YAD_WIDTH)
    # does not exceed TOTAL_WIDTH.
    elif [ "$((PROPOSED_POS_X + YAD_WIDTH))" -gt "$TOTAL_WIDTH" ]; then # MODIFIED LINE
        pos_x=$((TOTAL_WIDTH - YAD_WIDTH - BORDER_SIZE)) # MODIFIED LINE (keep BORDER_SIZE for safety margin if WM applies it)
    else
        pos_x=$PROPOSED_POS_X
    fi

    # Y position calculation
    # We want to open Yad below the click (Y), respecting BAR_HEIGHT
    if [ "$Y" -gt "$((TOTAL_HEIGHT / 2))" ]; then # If click is in bottom half of screen
        # Place above the click, accounting for total height and bar
        pos_y=$((TOTAL_HEIGHT - YAD_HEIGHT - BAR_HEIGHT - BORDER_SIZE))
    else # If click is in top half of screen
        # Place below the click, accounting for bar height
        pos_y=$((BAR_HEIGHT + BORDER_SIZE))
    fi

    # Debugging output (optional - uncomment to use)
    # echo "Mouse X: $X, Mouse Y: $Y" > /tmp/yad_debug.log
    # echo "Total Virtual Desktop: ${TOTAL_WIDTH}x${TOTAL_HEIGHT}" >> /tmp/yad_debug.log
    # echo "PROPOSED_POS_X: $PROPOSED_POS_X" >> /tmp/yad_debug.log
    # echo "Calculated pos_x: $pos_x, Calculated pos_y: $pos_y" >> /tmp/yad_debug.log


    yad --calendar --undecorated --fixed --close-on-unfocus --no-buttons \
        --width="$YAD_WIDTH" --height="$YAD_HEIGHT" --posx="$pos_x" --posy="$pos_y" \
        --title="yad-calendar" --borders=0 >/dev/null &
    ;;
*)
    echo "$DATE"
    ;;
esac