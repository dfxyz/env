#!/bin/sh

cd "$(dirname "$0")" || exit 1

source ../common.sh

[[ -n $onLinux ]] && targetDir="$HOME/.config/Windsurf/User" || targetDir="$APPDATA/Windsurf/User"

copyInto keybindings.json "$targetDir"
copyInto settings.json "$targetDir"

if [[ -n $onLinux ]]; then
    copyInto windsurf.desktop "$HOME/.local/share/applications"
    if [[ -e /opt/Windsurf/bin/windsurf ]]; then
        mkdir -p "$HOME/.local/bin"
        if [[ -L "$HOME/.local/bin/windsurf" ]]; then
            rm "$HOME/.local/bin/windsurf"
        fi
        ln -s /opt/Windsurf/bin/windsurf "$HOME/.local/bin" || exit $?
        echo "Symlink created at '$HOME/.local/bin/windsurf'."
    fi
fi
