[[ "$(uname -s)" == "Linux" ]] && onLinux=yes

# Usage: __copy <source> <destination> <destinationIsParentDir>
function __copy() {
    if [[ $3 == 0 ]]; then
        target="$2"
        targetDir="$(dirname "$2")"
    else
        target="$2/$(basename "$1")"
        targetDir="$2"
    fi

    mkdir -p "$targetDir"; retcode=$?
    if [[ $retcode != 0 ]]; then
        echo "Failed to create directory at '$targetDir'."
        return 1
    fi

    if [[ -L "$target" ]]; then
        rm "$target"
    elif [[ -e "$target" ]]; then
        read -p "Remove existing item at '$target'? [y/N] " answer
        if [[ $answer != "y" && $answer != "Y" ]]; then
            mv "$target" "$target.bak"; retcode=$?
            if [[ $retcode != 0 ]]; then
                echo "Failed to backup existing item at '$target'."
                return $retcode
            fi
            echo "Existing item backed up to '$target.bak'."
        else
            rm "$target"; retcode=$?
            if [[ $retcode != 0 ]]; then
                echo "Failed to remove existing item at '$target'."
                return $retcode
            fi
        fi
    fi

    cp -r "$1" "$1.tmp" || return 100
    __scanOptions "$1.tmp"
    if [[ ${#__options[@]} > 0 ]]; then
        for option in "${__options[@]}"; do
            if [[ $option == "linux" ]]; then
                if [[ -n $onLinux ]]; then
                    __enableOption "$1.tmp" "$option"
                else
                    __disableOption "$1.tmp" "$option"
                fi
            elif [[ $option == "windows" ]]; then
                if [[ -n $onLinux ]]; then
                    __disableOption "$1.tmp" "$option"
                else
                    __enableOption "$1.tmp" "$option"
                fi
            else
                read -p "Enable option '$option' in '$1'? [y/N] " answer
                if [[ $answer != "y" && $answer != "Y" ]]; then
                    __disableOption "$1.tmp" "$option"
                else
                    __enableOption "$1.tmp" "$option"
                fi
            fi
        done
    fi
    unset __options

    mv "$1.tmp" "$target"; retcode=$?
    if [[ $retcode != 0 ]]; then
        echo "Failed to copy item to '$target'."
        return $retcode
    fi
    echo "Item copied to '$target'."
}

# Usage: __scanOptions <source>; result is stored to variable `__options`
function __scanOptions() {
    __options=()
    local sourceFile="$1"
    if [[ ! -f "$sourceFile" ]]; then
        return 1
    fi

    local awkScript='match($0, /^[[:space:]]*[^[:space:]]+[[:space:]]*__\[option\(([[:alnum:]]+)\)\]__$/, m) { if (m[1] != "") print m[1] }'
    local options
    options=$(awk "$awkScript" "$sourceFile" | sort -u)
    if [[ -n "$options" ]]; then
        readarray -t __options <<< "$options"
    fi
}

# Usage: __enableOption <source> <optionName>
function __enableOption() {
    local awkScript='
    BEGIN {
        matching = 0
    }
    match($0, "^[[:space:]]*([^[:space:]]+)[[:space:]]*__\\[option\\(" optionName "\\)\\]__$", m) {
        matching = 1
        commentTokens = m[1]
        next
    }
    {
        if (matching == 0) {
            print
            next
        }
    }
    match($0, "__end__$", m) {
        matching = 0
        next
    }
    {
        gsub("^[[:space:]]*" commentTokens "[[:space:]]?", "")
        print
    }
    '
    awk -i inplace -v optionName="$2" "$awkScript" "$1"
}

# Usage: __disableOption <source> <optionName>
function __disableOption() {
    local awkScript='
    BEGIN {
        matching = 0
    }
    match($0, "^[[:space:]]*([^[:space:]]+)[[:space:]]*__\\[option\\(" optionName "\\)\\]__$", m) {
        matching = 1
        commentTokens = m[1]
        next
    }
    {
        if (matching == 0) {
            print
            next
        }
    }
    match($0, "__end__$", m) {
        matching = 0
        next
    }
    '
    awk -i inplace -v optionName="$2" "$awkScript" "$1"
}

# Usage: copyAs <source> <target>
function copyAs() {
    __copy "$1" "$2" 0
}

# Usage: copyInto <source> <targetDir>
function copyInto() {
    __copy "$1" "$2" 1
}
