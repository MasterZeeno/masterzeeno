#!/bin/zsh

is_latest() {
  local d1="$1" d2="$2"
  [[ -z "$d1" || -z "$d2" ]] && return 1

  local ts1 ts2
  ts1=$(date -d "$d1" +%s 2>/dev/null) || return 1
  ts2=$(date -d "$d2" +%s 2>/dev/null) || return 1

  (( ts1 >= ts2 ))
}

get_latest_date() {
  local repo_owner="$1"
  local repo_name="$2"
  local local file_path="$3"
  curl -s "https://api.github.com/repos/$repo_owner/$repo_name/commits?path=$file_path&per_page=1" | grep -m1 '"date":' | cut -d'"' -f4
}

view_file_online() {
  local repo_owner="$1"
  local repo_name="$2"
  local file_path="$3"
  curl -s "https://raw.githubusercontent.com/$repo_owner/$repo_name/refs/heads/master/$file_path"
}

push_repo() {
  git diff --quiet && return
  
  local name="${1:-$USER_NAME}"
  local email="${2:-$USER_EMAIL}"
  [[ "$email" =~ ^@ ]] && email="$name$email"
  
  shift $(( $# > 2 ? 2 : $# ))
  
  git config --global user.name "$name"
  git config --global user.email "$email"
  
  local -a to_add=() msgs=()
  for arg in "$@"; do
    [[ -e "$arg" ]] && to_add+=("$arg") || msgs+=("$arg")
  done

  (( ${#to_add[@]} )) || to_add=(${(@f)$(git diff --name-only)})
  git add "${to_add[@]}"
  git commit -m "${msgs[*]:-Updated on: $(date)}"
  git push
}

abrv() {
  echo "$1" | sed -E 's/([a-zA-Z]+)|([0-9]+)/\n\1\2/g' | \
    sed '/^$/d' | sed -E 's/^([a-zA-Z]).*/\1/' | paste -sd ''
}

update_colors_var() {
  local varfilepath="$1"
  mkdir -p "${varfilepath:h}"
  touch "$varfilepath"

  local repo_owner="romkatv"
  local repo_name="powerlevel10k"
  local filepath="internal/$(abrv $repo_name).zsh"

  local current_date=$(head -n1 "$varfilepath" | sed 's/[#\s]//g')
  local latest_date=$(get_latest_date "$repo_owner" "$repo_name" "$filepath")

  if ! is_latest "$current_date" "$latest_date"; then
      echo "# $latest_date" > "$varfilepath"
      view_file_online "$repo_owner" "$repo_name" "$filepath" | \
          sed -n "/^typeset.*${varfilepath:t}=(/,/)/p" >> "$varfilepath"
    
    push_repo "github-actions[bot]" "@users.noreply.github.com" \
      "$varfilepath" "Updated on: $latest_date"
  fi
}

update_colors_var "cache/__p9k_colors"