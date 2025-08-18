#!/bin/sh

cd "$(dirname "$0")" || exit 1

echo "Enter the path to neovide executable: (default = D:\\bin\\neovide.exe)"
read -r -p ">> " neovidePath

if [[ -z $neovidePath ]]; then
    neovidePath="D:\\bin\\neovide.exe"
fi
neovidePath="${neovidePath//\\/\\\\}"

iconv -f UTF-8 -t UTF-16LE - > __temp.reg.0 << EOF
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\*\shell\neovide]
@="通过 Neovide 打开"
"icon"="$neovidePath,0"

[HKEY_CLASSES_ROOT\*\shell\neovide\command]
@="$neovidePath \"%1\""

EOF
printf "\xFF\xFE" | cat - __temp.reg.0 > __temp.reg
cwd="$(cygpath -w "$PWD")"
sudo powershell -Command "reg import \"$cwd\\__temp.reg\"; Remove-Item \"$cwd\\__temp.reg*\""
