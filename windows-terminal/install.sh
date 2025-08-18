#!/bin/sh

cd "$(dirname "$0")" || exit 1

source ../common.sh

dirName=$(ls "$LOCALAPPDATA/Packages" | grep "Microsoft.WindowsTerminal")
targetDir="$LOCALAPPDATA/Packages/$dirName/LocalState"
if [[ ! -d "$targetDir" ]]; then
    echo "Failed to find the target directory."
    exit 1
fi

copyInto settings.json "$targetDir"
