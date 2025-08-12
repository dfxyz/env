#!/bin/sh

cd "$(dirname "$0")" || exit 1

source ../common.sh

copyAs gitconfig "$HOME/.gitconfig"
