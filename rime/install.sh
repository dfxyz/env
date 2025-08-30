#!/bin/sh

cd "$(dirname "$0")" || exit 1

source ../common.sh

[[ -n $onLinux ]] && rimeDir="$HOME/.local/share/fcitx5/rime" || rimeDir="$APPDATA/Rime"

for item in conf/*; do
    copyInto "$item" "$rimeDir"
done

if [[ -n $onLinux ]]; then
    copyAs theme/fcitx5.conf "$rimeDir/../themes/CandyPaper/theme.conf"
else
    copyInto theme/weasel.yaml "$rimeDir"
fi

sh "$rimeDir/update_dict.sh" || exit 1
