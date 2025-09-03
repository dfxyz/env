#!/bin/sh

cd "$(dirname "$0")" || exit 1

source ../common.sh

[[ -n $onLinux ]] && mpvConfDir="$HOME/.config/mpv" || mpvConfDir="$APPDATA/mpv"

copyInto mpv.conf "$mpvConfDir"
copyInto input.conf "$mpvConfDir"
copyInto rememberSettings.lua "$mpvConfDir/scripts"
tar -xzf shaders.tar.gz -C "$mpvConfDir"
