#!/bin/sh

cd "$(dirname "$0")" || exit 1

mkdir -p dicts

dictSource="rime-ice"
dictSourceGitUrl="https://github.com/iDvel/rime-ice.git"
#dictSource="rime-frost"
#dictSourceGitUrl="https://github.com/gaboolic/rime-frost.git"
dictFiles=(
    8105.dict.yaml
    base.dict.yaml
    ext.dict.yaml
    others.dict.yaml
    tencent.dict.yaml
)

if [[ -d $dictSource ]]; then
    pushd "$dictSource" || exit 1
    git pull || exit 1
    popd || exit 1
else
    git clone "$dictSourceGitUrl" || exit 1
fi
for file in "${dictFiles[@]}"; do
    rsync -ahvP "$dictSource/cn_dicts/$file" "dicts/" || exit 1
done
