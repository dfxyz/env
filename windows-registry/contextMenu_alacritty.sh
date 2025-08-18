#!/bin/sh

cd "$(dirname "$0")" || exit 1

echo "Enter the path to alacritty executable: (default = D:\\bin\\alacritty.exe)"
read -r -p ">> " alacrittyPath

if [[ -z $alacrittyPath ]]; then
    alacrittyPath="D:\\bin\\alacritty.exe"
fi
alacrittyPath="${alacrittyPath//\\/\\\\}"

iconv -f UTF-8 -t UTF-16LE - > __temp.reg.0 << EOF
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\Directory\shell\alacritty]
@="通过 Alacritty 打开"
"icon"="$alacrittyPath,0"

[HKEY_CLASSES_ROOT\Directory\shell\alacritty\command]
@="$alacrittyPath --working-directory \"%V\""

[HKEY_CLASSES_ROOT\Directory\Background\shell\alacritty]
@="通过 Alacritty 打开"
"icon"="$alacrittyPath,0"

[HKEY_CLASSES_ROOT\Directory\Background\shell\alacritty\command]
@="$alacrittyPath --working-directory \"%V\""

EOF
printf "\xFF\xFE" | cat - __temp.reg.0 > __temp.reg
cwd="$(cygpath -w "$PWD")"
sudo powershell -Command "reg import \"$cwd\\__temp.reg\"; Remove-Item \"$cwd\\__temp.reg*\""
