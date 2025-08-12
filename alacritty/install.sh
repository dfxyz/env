#!/bin/sh

cd "$(dirname "$0")" || exit 1

source ../common.sh

[[ -n $onLinux ]] && targetDir="$HOME/.config/alacritty" || targetDir="$APPDATA/alacritty"

copyInto alacritty.toml "$targetDir"
