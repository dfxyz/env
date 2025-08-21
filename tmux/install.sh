#!/bin/sh

cd "$(dirname "$0")" || exit 1

source ../common.sh

copyAs tmux.conf "$HOME/.tmux.conf"
