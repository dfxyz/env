#!/bin/sh

cd "$(dirname "$0")" || exit 1

[[ -n "$APPDATA" ]] && targetDir="$APPDATA/alacritty" || targetDir="$HOME/.config/alacritty"

targetFiles=(
    "$targetDir/alacritty.toml"
)

case $1 in
    i|install)
        mkdir -p "$targetDir" || exit 1
        for file in ${targetFiles[@]}; do
            cp -i "$(basename "$file")" "$file"
        done
        exit 0
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

