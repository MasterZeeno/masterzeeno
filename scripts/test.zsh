#!/data/data/com.termux/files/usr/bin/zsh

# is_latest() {
  # local d1="$1" d2="$2"
  # [[ -z "$d1" || -z "$d2" ]] && return 1

  # local ts1 ts2
  # ts1=$(date -d "$d1" +%s 2>/dev/null) || return 1
  # ts2=$(date -d "$d2" +%s 2>/dev/null) || return 1

  # (( ts1 >= ts2 ))
# }

# get_latest_date() {
  # local repo_owner="$1"
  # local repo_name="$2"
  # local local file_path="$3"
  # curl -s "https://api.github.com/repos/$repo_owner/$repo_name/commits?path=$file_path&per_page=1" | grep -m1 '"date":' | cut -d'"' -f4
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

# abrv() {
  # echo "$1" | sed -E 's/([a-zA-Z]+)|([0-9]+)/\n\1\2/g' | \
    # sed '/^$/d' | sed -E 's/^([a-zA-Z]).*/\1/' | paste -sd ''
# }

# update_colors_var() {
  # local varfilepath="$1"
  # mkdir -p "${varfilepath:h}"
  # touch "$varfilepath"

  # local repo_owner="romkatv"
  # local repo_name="powerlevel10k"
  # local filepath="internal/$(abrv $repo_name).zsh"

  # local current_date=$(head -n1 "$varfilepath" | sed 's/[#\s]//g')
  # local latest_date=$(get_latest_date "$repo_owner" "$repo_name" "$filepath")

  # if ! is_latest "$current_date" "$latest_date"; then
      # echo "# $latest_date" > "$varfilepath"
      # view_file_online "$repo_owner" "$repo_name" "$filepath" | \
          # sed -n "/^typeset.*${varfilepath:t}=(/,/)/p" >> "$varfilepath"
    
    # push_repo "github-actions[bot]" "@users.noreply.github.com" \
      # "$varfilepath" "Updated on: $latest_date"
  # fi
# }

# update_colors_var "cache/__p9k_colors"

# translate_color() {
  # if [[ $1 == <-> ]]; then
    # color=${(l.3..0.)1}
  # elif [[ $1 =~ '^#?[[:xdigit:]]{3,}$' ]]; then
    # color='#'${${${(L)1//#/}//ı/i}:0:6}
  # else
    # color=$__p9k_colors[${${${1#bg-}#fg-}#br}]
  # fi
# }

# color="${1:-31}"
# translate_color "$color"
# print -rP "%F{$color}Test%f"

# get_xterm_color() {
  # local query=$1
  # # 10 = foreground, 11 = background
  # exec 3<> /dev/tty
  # printf '\e]%s;?\a' "$query" > /dev/tty
  # IFS=';' read -r -d $'\a' _ response <&3
  # echo "${response#rgb:}" | sed 's:/: :g'
  # exec 3>&-
# }
# colors=(red green yellow blue magenta cyan white)
# for color in "${colors[@]}"; do
  # echo "$__p9k_colors[$color]"
# done

# test() {
  # local -a fmts=(b d i)
  # local -T fmts_key_str fmts_key_arr=(1 2 3) ';'
  # local -i idx=$(($1>$#fmts_val_arr?$#fmts_val_arr:$1))
  # ((idx)) && echo $fmts_val_arr[$idx] || echo $fmt_arr[@]
# }

# test "${1:-0}"

test() {
  local prop_file="$HOME/.termux/colors.properties"
  local -a colors=(black red green yellow blue magenta cyan white)
  local -i num max="$#colors"
  local -l prfx key value
  
  local -A terminal_colors
  while IFS='=' read -r key value; do
    [[ -z $key || $key == \#* ]] && continue
    
    case "$key" in
      color*)
        unset prfx
        num=$((${key//[^0-9]/}+1))
        ((num>max)) && { num=$((num-max)); prfx="br-"; }
        key="${prfx:-}${colors[$num]}" ;;
      cursor) continue ;;
      *) ;;
    esac
    
    terminal_colors[$key]="${value}"
  done < "$prop_file"
  
  echo "${(kv)terminal_colors}"
  return
  
  
  local p prop
  
  for p in fore back {0..15}; do
    case "$p" in
      [0-9]*) prop="color$p" ;;
      *) prop="${p}ground"
    esac
    echo "$prop"
  done
}

# test

