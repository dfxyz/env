#!/bin/sh

cd "$(dirname "$0")" || exit 1

source ../common.sh

copyInto konsolerc "$HOME/.config"
copyInto konsole.profile "$HOME/.local/share/konsole"
copyInto konsole.colorscheme "$HOME/.local/share/konsole"
