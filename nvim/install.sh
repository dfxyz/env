#!/bin/sh

cd "$(dirname "$0")" || exit 1

source ../common.sh

[[ -n $onLinux ]] && targetDir="$HOME/.config/nvim" || targetDir="$LOCALAPPDATA/nvim"
pluginDir="$targetDir/pack/default/start"

copyInto init.vim "$targetDir" || exit $?

declare -A plugins
for url in $(cat plugins.txt); do
    dirName=$(basename "$url" | sed 's/\.git$//')
    plugins[$dirName]="$url"
done
if [[ ${#plugins[@]} == 0 ]]; then
    exit 0
fi
mkdir -p "$pluginDir" || exit 1
cd "$pluginDir" || exit 1
for name in ${!plugins[@]}; do
    if [[ -d "$name" ]]; then
        echo "Skip cloning plugin '$name'."
    else
        git clone "${plugins[$name]}"; retcode=$?
        if [[ $retcode != 0 ]]; then
            echo "Failed to clone plugin '$name'."
            exit $retcode
        fi
    fi
done
