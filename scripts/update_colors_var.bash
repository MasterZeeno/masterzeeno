#!/usr/bin/env bash

mktouch() {
    [[ -z "$1" ]] && return 1
    local dir=$(dirname "$1")
    mkdir -p "$dir" && touch "$1"
}

is_not_latest() {
    [[ -z "$1" ]] && return
    local v1="${1#v}" v2="${2#v}"
    local latest=$(printf '%s\n' "$v1" "$v2" | sort -V | tail -n1)
    [[ "$v1" != "$latest" ]]
}

get_latest_release() { 
    local repo_owner="$1"
    local repo_name="$2"
    curl -s "https://api.github.com/repos/$repo_owner/$repo_name/releases/latest" | grep -oE '"tag_name": *"[^"]+"' | cut -d'"' -f4
}

view_file_online() {
    local repo_owner="$1"
    local repo_name="$2"
    local file_path="$3"
    curl -s "https://raw.githubusercontent.com/$repo_owner/$repo_name/refs/heads/master/$file_path"
}

update_colors_var() {
    local var='__p9k_colors'
    local file="../cache/$var"
    mktouch "$file"

    local repo_owner="romkatv"
    local repo_name="powerlevel10k"
    local file_path="internal/p10k.zsh"

    local current_version=$(head -n1 "$file" | sed -e 's/[#\s]//g')
    local latest_version=$(get_latest_release "$repo_owner" "$repo_name")

    if is_not_latest "$current_version" "$latest_version"; then
        echo "Updating $var..."
        echo "# $latest_version" > "$file"
        view_file_online "$repo_owner" "$repo_name" "$file_path" | \
            sed -n "/^typeset.*${var//\//\\/}=(/,/)/p" >> "$file"
    fi
}

update_colors_var
