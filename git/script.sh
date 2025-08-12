#!/bin/sh

cd "$(dirname "$0")" || exit 1

case $1 in
    i|install)
        cp -i gitconfig "$HOME/.gitconfig" || exit 1
        ;;

    d|diff)
        if [[ ! -e "$HOME/.gitconfig" ]]; then
            echo "File '$HOME/.gitconfig' does not exist."
            exit 1
        fi
        diff --color=auto gitconfig "$HOME/.gitconfig"
        ;;

    e|edit)
        if [[ ! -e "$HOME/.gitconfig" ]]; then
            echo "File '$HOME/.gitconfig' does not exist."
            exit 1
        fi
        $EDITOR gitconfig
        ;;

    *)
        echo "Usage: $0 {install|diff|edit}"
        exit 1
        ;;
esac
