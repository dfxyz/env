#!/bin/bash

cd "$(dirname "$0")" || exit 1

targetFiles=(
    "$HOME/.config/konsolerc"
    "$HOME/.local/share/konsole/konsole.profile"
    "$HOME/.local/share/konsole/konsole.colorscheme"
)

case $1 in
    i|install)
        mkdir -p "$HOME/.config" || exit 1
        mkdir -p "$HOME/.local/share/konsole" || exit 1
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
