#!/data/data/com.termux/files/usr/bin/zsh


# test() {
    # local var='__p9k_colors'
    # local file="./cache/$var"
    # local repo_owner="romkatv"
    # local repo_name="powerlevel10k"
    # local file_path="internal/p10k.zsh"
    
    # [[ -s "$file" ]] || echo '# v0.0.0' > "$file"
    # local current_version=$(head -n1 "$file")
    
        # local contents=(
            # "$(get_latest_release "$repo_owner" "$repo_name")"
            # "$(view_file_online "$repo_owner" "$repo_name" "$file_path" | \
                # sed -n "/^typeset.*$var=(/,/)/p")")
            
            
        # fi
        # local latest_release="$(get_latest_release "$repo_owner" "$repo_name")"
        # source "$file"
    # fi
    # echo "${(P)var}"
# }

# get_latest_release() { 
    # local repo_owner="$1"
    # local repo_name="$2"
    # curl -s "https://api.github.com/repos/$repo_owner/$repo_name/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
# }

# get_latest_release 'romkatv' 'zsh-bin'

# view_file_online() {
    # local repo_owner="$1"
    # local repo_name="$2"
    # local file_path="$3"
    # curl -s "https://raw.githubusercontent.com/$repo_owner/$repo_name/refs/heads/master/$file_path"
# }

# # get_latest_release "romkatv" "powerlevel10k"

# test


# url='https://raw.githubusercontent.com/romkatv/zsh-bin/refs/heads/master/build'
# aria2c -x 16 -s 64 -j 1 \
  # --max-tries=3 --retry-wait=2 -d "." "$url"

# push_repo() {
  # local name="${1:-github-actions[bot]}"
  # local email="${2:-$name@users.noreply.github.com}"
  # local -i i=$#; ((i>2)) && i=2; (($#)) && shift $i
  
  # local -a unstaged=($(git diff --name-only))
  # local -a to_add msgs
  # for arg in "$@"; do
    # [[ -e "$arg" ]] && to_add+=("$arg") || msgs+=("$arg")
  # done

  # for p in name email; do
    # git config --global user.$p "${(P)p}"
  # done
  
  # git add "${to_add[@]:-${unstaged[@]}}"
  # git commit -m "${msgs[*]:-Updated on: $(date)}"
  # git push
# }

push_repo() {
  git diff --quiet && return
  
  local name="${1:-github-actions[bot]}"
  local email="${2:-$name@users.noreply.github.com}"
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

typeset -a args
(($#)) && args=("$@") || \
  args=(
    'masterzeeno'
    'zeenoliev@gmail.com'
    '../cache/__p9k_colors'
    'Updated to: v1.20.0'
  )
push_repo "${args[@]}"
