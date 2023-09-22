#!/usr/bin/env bash
# lightson+

# Copyright (c) 2018 spinal.by at gmail com
# Copyright (c) 2014 devkral at web de
# url: https://github.com/devkral/lightsonplus

#based on
# Copyright (c) 2011 iye.cba at gmail com
# url: https://github.com/iye/lightsOn
# This script is licensed under GNU GPL version 2.0 or above

# Heavily modified version of
# url: https://github.com/devkral/lightsonplus

# Description: Bash script that prevents the screensaver and display power
# management (DPMS) from being activated while watching fullscreen videos
# on Firefox, Chrome and Chromium. Media players like mplayer, VLC and minitube
# can also be detected.
# One of {x, k, gnome-}screensaver must be installed.

# HOW TO USE:
# "./lightson+ -d 2 &" will check every 2 seconds if Mplayer, VLC, Firefox or
# Chromium are fullscreen and delay screensaver and Power Management if so.
# If you don't pass an argument, the checks are done every minute.

# Select the programs to be checked
mpv_detection=0
mplayer_detection=0
plex_detection=1
vlc_detection=1
totem_detection=1
firefox_flash_detection=1
chromium_flash_detection=1
#chrome_app_name="Netflix"
webkit_flash_detection=1
flash_detection=1
html5_detection=1
steam_detection=0
minitube_detection=0
audio_detection=1
only_fullscreen=0
#minload=1.5
delay_seconds=60
# You can find the value for this with `xprop WM_NAME`
# (click on the window once the mouse is a crosshair)
window_name=""

declare -A checked_apps=(
    [mpv]=0
    [mplayer]=0
    [plexmediaplayer]=0
    [plex]=1
    [vlc]=0
    [totem]=0
    [steam]=0
    [minitube]=0
)

# realdisp
realdisp=$(echo "$DISPLAY" | cut -d. -f1)

inhibitfile="/tmp/lightsoninhibit-$UID-$realdisp"
pidfile="/tmp/lightson-$UID-$realdisp.pid"

# YOU SHOULD NOT NEED TO MODIFY ANYTHING BELOW THIS LINE
die() {
    echo "$@" >&2
    exit 1
}

pidcreate() {
    # just one instance can run simultaneously
    if [ ! -e "$pidfile" ]; then
        echo "$$" >"$pidfile"
    else
        if [ -d "/proc/$(cat "$pidfile")" ]; then
            die "Another instance is running, abort!"
        else
            echo "$$" >"$pidfile"
        fi
    fi
}

# shellcheck disable=2317
pidremove() {
    if [ ! -e "$pidfile" ]; then
        echo "Error: missing pidfile" >&2
    elif [ ! -f "$pidfile" ]; then
        echo -e "Error: \"$pidfile\" is not a file\n" >&2
    else
        if [ "$(cat "$pidfile")" != "$$" ]; then
            die "Another instance is running, abort!"
        else
            rm -f "$pidfile"
        fi
    fi
    exit 0
}

pidcreate
trap "pidremove" EXIT

# Enumerate all the attached screens
displays=""
while read -r id; do
    displays="$displays $id"
done < <(xvinfo | sed -n 's/^screen #\([0-9]\+\)$/\1/p')

# Detect screensaver being used
if dbus-send --session --print-reply=literal --type=method_call --dest=org.freedesktop.ScreenSaver /ScreenSaver/ org.freedesktop.ScreenSaver.GetActive &>/dev/null; then
    screensaver="freedesktop-screensaver"
elif [ $(pgrep -c xscreensaver) -ge 1 ]; then
    screensaver="xscreensaver"
elif [ $(pgrep -c mate-screensaver) -ge 1 ]; then
    screensaver="mate-screensaver"
elif [ $(pgrep -c xautolock) -ge 1 ]; then
    screensaver="xautolock"
elif [ -e "/usr/bin/xdotool" ]; then
    screensaver="xdofallback"
else
    screensaver=""
    die "No screensaver detected"
fi

check() {
    if [ "$only_fullscreen" = 1 ]; then
        checkFullscreen
    else
        checkNonFullscreen
    fi
}

checkFullscreen() {
    # loop through every display looking for a fullscreen window
    for display in $displays; do
        # get id of active window and clean output
        active_win_id=$(DISPLAY=$realdisp.${display} xprop -root _NET_ACTIVE_WINDOW)
        active_win_id=${active_win_id##*# }
        active_win_id=${active_win_id:0:9} # eliminate potentially trailing spaces

        top_win_id=$(DISPLAY=$realdisp.${display} xprop -root _NET_CLIENT_LIST_STACKING)
        top_win_id=${active_win_id##*, }
        top_win_id=${top_win_id:0:9} # eliminate potentially trailing spaces

        # Check if Active Window (the foremost window) is in fullscreen state
        if [ ${#active_win_id} -ge 3 ] && [ "$active_win_id" != 0x0 ]; then
            isActiveWinFullscreen=$(DISPLAY=$realdisp.${display} xprop -id "$active_win_id" | grep _NET_WM_STATE_FULLSCREEN)
        else
            isActiveWinFullscreen=""
        fi
        if [ ${#top_win_id} -ge 3 ] && [ "$top_win_id" != 0x0 ]; then
            isTopWinFullscreen=$(DISPLAY=$realdisp.${display} xprop -id "$top_win_id" | grep _NET_WM_STATE_FULLSCREEN)
        else
            isTopWinFullscreen=""
        fi

        if [ -n "$window_name" ]; then
            isNamedFullscreen=$(DISPLAY=$realdisp.${display} xprop -name "$window_name" | grep _NET_WM_STATE_FULLSCREEN)
        else
            isNamedFullscreen=""
        fi

        if [[ "$isActiveWinFullscreen" = *NET_WM_STATE_FULLSCREEN* ]] || [[ "$isTopWinFullscreen" = *NET_WM_STATE_FULLSCREEN* ]]; then
            local active_win_title
            active_win_title=$(xprop -id "$active_win_id" | grep "WM_CLASS(STRING)" | sed 's/^.*", //;s/"//g')

            isAppRunningParam "$active_win_title" && delayScreensaver
        fi

        # If we are detecting by named application, then we need to detect if any audio is playing.
        # Detecting by name is used for multiple monitors where the video might be playing, but
        # not in focus.
        if [[ "$isNamedFullscreen" = *NET_WM_STATE_FULLSCREEN* ]]; then
            checkAudioPlaying && delayScreensaver
        fi
    done
}

checkNonFullscreen() {
    local window_ids
    window_ids=$(xdotool search --onlyvisible --name '')

    # Declare an array to store unique window titles
    declare -a unique_titles=()

    # Iterate through the window IDs and retrieve their titles
    for window_id in $window_ids; do
        window_title=$(xprop -id "$window_id" | grep "WM_CLASS(STRING)" | sed 's/^.*", //;s/"//g')

        # Check if window_title is not empty and not already in the unique_titles array
        if [ -n "$window_title" ] && ! [[ " ${unique_titles[*]} " =~ $window_title ]]; then
            unique_titles+=("$window_title")
            isAppRunningParam "$window_title" && checkAudioPlaying && delayScreensaver
        fi
    done
}

# Check if active window is mplayer, vlc or firefox
# Then change IFs to detect more specifically the apps "<vlc>" and if process name exist
isAppRunningParam() {
    # Get title of window
    local win_title="$1"

    for app in "${!checked_apps[@]}"; do
        grep -iq "$app" <<<"$win_title" &&
            [ "${checked_apps[$app]}" = 1 ] &&
            [ $(pgrep -ic "$app") -ge 1 ] &&
            checkAudio "$app" &&
            return 0
    done

    [ "$html5_detection" = 1 ] && for app in chromium chrome firefox brave opera epiphany; do
        grep -iq "$app" <<<"$win_title" &&
            [ $(pgrep -ic "$app") -ge 1 ] &&
            checkAudio "$app" &&
            return 0
    done

    # case "$win_title" in
    # *[Cc]hromium*)
    #     [ "$chromium_flash_detection" = 1 ] && [ $(pgrep -fc "chromium --type=ppapi") -ge 1 ] && return 0
    #     [ "$html5_detection" = 1 ] && [ $(pgrep -c chromium) -ge 1 ] && checkAudio "chromium" && return 0
    #     ;;
    # *[Cc]hrome*)
    #     [ "$chromium_flash_detection" = 1 ] && [ $(pgrep -fc "chrome --type=ppapi") -ge 1 ] && return 0
    #     [ "$html5_detection" = 1 ] && [ $(pgrep -c chrome) -ge 1 ] && checkAudio "chrom" && return 0
    #     ;;
    # *[Ff]irefox*)
    #     [ "$html5_detection" = 1 ] && [ $(pgrep -fc firefox) -ge 1 ] && checkAudio "firefox" && return 0
    #     ;;
    # *[Ll]ibre[wW]olf*)
    #     [ "$html5_detection" = 1 ] && [ $(pgrep -fc librewolf) -ge 1 ] && checkAudio "librewolf" && return 0
    #     ;;
    [ "$flash_detection" = 1 ] && case "$win_title" in
    *chromium*)
        [ $(pgrep -ifc "chromium --type=ppapi") -ge 1 ] && return 0
        ;;
    *chrome*)
        [ $(pgrep -ifc "chrome --type=ppapi") -ge 1 ] && return 0
        ;;
    *brave*)
        [ $(pgrep -ifc "brave --type=ppapi") -ge 1 ] && return 0
        ;;
    *unknown* | *plugin-container*) # firefox
        [ $(pgrep -ic plugin-container) -ge 1 ] && return 0
        ;;
    *webKitpluginprocess*)
        [ $(pgrep -ifc ".*WebKitPluginProcess.*flashp.*") -ge 1 ] && return 0
        ;;
    esac

    if [ -n "$chrome_app_name" ]; then
        # Check if google chrome is running in app mode
        grep -iq "$chrome_app_name" <<<"$win_title" && [ $(pgrep -ifc "chrome --app") -ge 1 ] && return 0
    fi

    [ -n "$minload" ] && [ "$(echo "$(sed 's/ .*$//' /proc/loadavg) > $minload" | bc -q)" -eq "1" ] && return 0

    false
}

checkAudioPlaying() {
    # Check if any application is playing sounds in pulse
    # This is useful if your application keeps the stream in pulse open
    # but, lists it as CORKED for example.
    # It's also useful if you watch videos on multiple monitors and might not
    # have the video in focus.
    [ "$audio_detection" = 0 ] && return 0
    pactl list short sinks | grep -iEq "RUNNING"
}

checkAudio() {
    # Check if application is streaming sound to PulseAudio
    [ "$audio_detection" = 0 ] && return 0
    pactl list sink-inputs | grep -iEq "application.name = .*$1.*"
}

delayScreensaver() {
    # Reset inactivity time counter so screensaver is not started
    case $screensaver in
    "xscreensaver")
        xscreensaver-command -deactivate >/dev/null
        ;;
    "mate-screensaver")
        mate-screensaver-command --poke >/dev/null
        ;;
    "xautolock")
        xautolock -disable
        xautolock -enable
        ;;
    "xdofallback")
        xdotool key shift
        ;;
    "freedesktop-screensaver")
        dbus-send --session --reply-timeout=2000 --type=method_call --dest=org.freedesktop.ScreenSaver /ScreenSaver org.freedesktop.ScreenSaver.SimulateUserActivity
        ;;
    esac

    # Check if DPMS is on. If it is, deactivate and reactivate again. If it is not, do nothing.
    dpmsStatus=$(xset -q | grep -c 'DPMS is Enabled')
    [ "$dpmsStatus" = 1 ] && xset -dpms && xset dpms
}

help() {
    echo "USAGE:    $ lighsonplus [FLAG1 ARG1] ... [FLAGn ARGn]"
    echo "FLAGS (ARGUMENTS must be 0 or 1, except stated otherwise):"
    echo ""
    echo "  -d,  --delay             Time interval in seconds, default is 60 seconds"
    echo "  -pa, --audio             Audio detection"
    echo "  -m,  --mpv               mpv detection"
    echo "  -mp, --mplayer           mplayer detection"
    echo "  -v,  --vlc               VLC detection"
    echo "  -t,  --totem             Totem detection"
    echo "  -pl, --plex-media-player Plex Media Player detection"
    echo "  -ff, --firefox-flash     Firefox flash plugin detection"
    echo "  -cf, --chromium-flash    Chromium flash plugin detection"
    echo "  -ca, --chrome-app        Chrome app detection, app name must be passed"
    echo "  -wf, --webkit-flash      Webkit flash detection"
    echo "  -h5, --html5             HTML5 detection"
    echo "  -s,  --steam             Steam detection"
    echo "  -mt, --minitube          MiniTube detection"
    echo "  -la, --minload           Load average detection"
    echo "  -wn, --window-name       Detect by window name"
    echo "  -of, --only-fullscreen   Only prevent screensaver if window is fullscreen"
}

checkBool() {
    [[ -n "$2" && $2 = [01] ]] || die "Invalid argument. 0 or 1 expected after \"$1\" flag."
}

while [ -n "$1" ]; do
    case $1 in
    "-d" | "--delay")
        [[ -z "$2" || "$2" = *[^0-9]* ]] && die "Invalid argument. Time in seconds expected after \"$1\" flag. Got \"$2\"" || delay_seconds=$2
        ;;
    "-ca" | "--chrome-app")
        if [ -n "$2" ]; then
            chrome_app_name="$2"
        else
            die "Missing argument. Chrome app name expected after \"$1\" flag."
        fi
        ;;

    "-wn" | "--window-name")
        if [ -n "$2" ]; then
            window_name="$2"
        else
            die "Missing argument. Window name expected after \"$1\" flag."
        fi
        ;;

    "-la" | "--minload")
        if [ -n "$2" ] && [[ "$(echo "$2 > 0" | bc -q)" -eq 1 ]]; then
            minload="$2"
        else
            die "Invalid argument. >0 expected after \"$1\" flag."
        fi
        ;;
    "-pa" | "--audio")
        checkBool "$@"
        audio_detection=$2
        ;;
    "-m" | "--mpv")
        checkBool "$@"
        mpv_detection=$2
        ;;
    "-mp" | "--mplayer")
        checkBool "$@"
        mplayer_detection=$2
        ;;
    "-v" | "--vlc")
        checkBool "$@"
        vlc_detection=$2
        ;;
    "-t" | "--totem")
        checkBool "$@"
        totem_detection=$2
        ;;
    "-pl" | "--plex-media-player")
        checkBool "$@"
        plex_detection=$2
        ;;
    "-ff" | "--firefox-flash")
        checkBool "$@"
        firefox_flash_detection=$2
        ;;
    "-cf" | "--chromium-flash")
        checkBool "$@"
        chromium_flash_detection=$2
        ;;
    "-wf" | "--webkit-flash")
        checkBool "$@"
        webkit_flash_detection=$2
        ;;
    "-h5" | "--html5")
        checkBool "$@"
        html5_detection=$2
        ;;
    "-s" | "--steam")
        checkBool "$@"
        steam_detection=$2
        ;;
    "-mt" | "--minitube")
        checkBool "$@"
        minitube_detection=$2
        ;;
    "-of" | "--only-fullscreen")
        checkBool "$@"
        only_fullscreen=$2
        ;;
    "-h" | "--help")
        help && exit 0
        ;;
    *)
        die "Invalid argument. See -h, --help for more information."
        ;;
    esac

    # Arguments must always be passed in tuples
    shift 2
done

# Convert delay to seconds. We substract 10 for assurance.
echo "Start prevent screensaver mainloop"

while true; do
    if [ -f "$inhibitfile" ]; then
        delayScreensaver
    else
        check
    fi

    sleep "$delay_seconds"
done

exit 0
