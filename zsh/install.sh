#!/bin/sh

cd "$(dirname "$0")" || exit 1

source ../common.sh

copyAs zshrc "$HOME/.zshrc"
copyAs zshenv "$HOME/.zshenv"
