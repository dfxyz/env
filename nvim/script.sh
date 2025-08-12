#!/bin/sh

cd "$(dirname "$0")" || exit 1

nvimConfigDir="$HOME/.config/nvim"
if [[ -n $LOCALAPPDATA ]]; then
    nvimConfigDir="$LOCALAPPDATA/nvim"
fi
targetFiles=(
    "$nvimConfigDir/init.vim"
)
declare -A plugins
for url in $(cat plugins.txt); do
    dirName=$(basename "$url" | sed 's/\.git$//')
    plugins[$dirName]="$url"
done

case $1 in
    i|install)
        mkdir -p "$nvimConfigDir" || exit 1
        for file in ${targetFiles[@]}; do
            cp -i "$(basename "$file")" "$file"
        done
        if [[ ${#plugins[@]} > 0 ]]; then
            mkdir -p "$nvimConfigDir/pack/default/start" || exit 1
            cd "$nvimConfigDir/pack/default/start" || exit 1
            for name in ${!plugins[@]}; do
                if [[ -d "$name" ]]; then
                    echo "Skip cloning '$name'."
                    continue
                fi
                git clone "${plugins[$name]}" || exit 1
            done
        fi
        ;;
    d|diff)
        for name in ${!plugins[@]}; do
            if [[ ! -e "$nvimConfigDir/pack/default/start/$name" ]]; then
                echo "Plugin '$nvimConfigDir/pack/default/start/$name' not installed."
                exit 1
            fi
        done
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
