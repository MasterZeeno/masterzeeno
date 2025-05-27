#!/bin/zsh

# sort_versions() {
  # printf '%s\n' "$@" | sort -V | tail -n1
# }

# is_latest() {
  # [[ -z "$1" || -z "$2" ]] && return 1
  # [[ "$1" == "$(sort_versions "$1" "$2")" ]]
# }

# get_latest_release() {
  # local repo_owner="$1"
  # local repo_name="$2"
  # curl -s "https://api.github.com/repos/$repo_owner/$repo_name/releases/latest" | grep -oE '"tag_name": *"[^"]+"' | cut -d'"' -f4
# }

# view_file_online() {
  # local repo_owner="$1"
  # local repo_name="$2"
  # local file_path="$3"
  # curl -s "https://raw.githubusercontent.com/$repo_owner/$repo_name/refs/heads/master/$file_path"
# }

# push_repo() {
  # git diff --quiet && return
  
  # local name="${1:-$USER_NAME}"
  # local email="${2:-$USER_EMAIL}"
  # [[ "$email" =~ ^@ ]] && email="$name$email"
  
  # shift $(( $# > 2 ? 2 : $# ))
  
  # git config --global user.name "$name"
  # git config --global user.email "$email"
  
  # local -a to_add=() msgs=()
  # for arg in "$@"; do
    # [[ -e "$arg" ]] && to_add+=("$arg") || msgs+=("$arg")
  # done

  # (( ${#to_add[@]} )) || to_add=(${(@f)$(git diff --name-only)})
  # git add "${to_add[@]}"
  # git commit -m "${msgs[*]:-Updated on: $(date)}"
  # git push
# }

# get_curr_version() {
  # [[ -f "$1" ]] || return
  # head -n1 "$1" | sed 's/[#\s]//g'
# }

# update_colors_var() {
  # local varfilepath="$1"
  # mkdir -p "${varfilepath:h}"
  # touch "$varfilepath"

  # local repo_owner="romkatv"
  # local repo_name="powerlevel10k"
  # local filepath="internal/p10k.zsh"

  # local current_version=$(get_curr_version "$varfilepath")
  # local latest_version=$(get_latest_release "$repo_owner" "$repo_name")

  # if ! is_latest "$current_version" "$latest_version"; then
      # echo "# $latest_version" > "$varfilepath"
      # view_varfilepath_online "$repo_owner" "$repo_name" "$filepath" | \
          # sed -n "/^typeset.*${varfilepath:t}=(/,/)/p" >> "$varfilepath"
  # fi
# }

# VARFILEPATH="cache/__p9k_colors"
# update_colors_var "$VARFILEPATH"
# push_repo "github-actions[bot]" "@users.noreply.github.com" \
  # "$VARFILEPATH" "Updated to: $(get_curr_version "$VARFILEPATH")"
  
is_latest() {
  local d1="$1" d2="$2"
  [[ -z "$d1" || -z "$d2" ]] && return 1

  local ts1 ts2
  ts1=$(date -d "$d1" +%s 2>/dev/null) || return 1
  ts2=$(date -d "$d2" +%s 2>/dev/null) || return 1

  (( ts1 >= ts2 ))
}

if is_latest "2025-05-27T10:00:00Z" "2024-12-01T15:00:00Z"; then
  echo "First date is latest"
else
  echo "First date is older"
fi
