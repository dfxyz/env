#!/bin/sh

cd "$(dirname "$0")" || exit 1

copyDesktopFile=1
targetDir="$HOME/.config/Windsurf/User"
if [[ -n $APPDATA ]]; then
    targetDir="$APPDATA/Windsurf/User"
    copyDesktopFile=0
fi

targetFiles=(
    "$targetDir/keybindings.json"
    "$targetDir/settings.json"
)
if [[ $copyDesktopFile != 0 ]]; then
    targetFiles+=("$HOME/.local/share/applications/windsurf.desktop")
fi

case $1 in
    i|install)
        mkdir -p "$targetDir" || exit 1
        for file in ${targetFiles[@]}; do
            cp -i "$(basename "$file")" "$file"
        done
    ;;

    d|diff)
        for file in ${targetFiles[@]}; do
            if [[ ! -e "$file" ]]; then
                echo "File '$file' does not exist."
                exit 1
            fi
        done
        for file in ${targetFiles[@]}; do
            diff --color=auto "$(basename "$file")" "$file"
        done
    ;;

    e|edit)
        for file in ${targetFiles[@]}; do
            if [[ ! -e "$file" ]]; then
                echo "File '$file' does not exist."
                exit 1
            fi
        done
        $EDITOR "${targetFiles[@]}"
    ;;

    *)
        echo "Usage: $0 {install|diff|edit}"
        exit 1
        ;;
esac
