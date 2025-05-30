#!/bin/zsh

fancy() {
  (($#)) || return
  
  (( $+__p9k_colors )) || builtin source "$ZEEDIR/cache/__p9k_colors"
  
  match_color() {
    local sub match query="${${(L)1#*-}//[^a-z0-9]/}"
    local -U keys=(${(k)__p9k_colors})
  
    for ((n=${#query}; n>=${#query}/2; n--)); do
      sub="${query:0:$n}"
      match=$(print -l $keys | grep \
        "^$sub" | sort -su | head -n1)
      if [[ -n "$match" ]]; then
        match=$__p9k_colors[$match]
        break
      fi
    done
  
    printf '%03d\n' "${match:-7}"
  }
  
  translate_color() {
    if [[ $1 == <-> ]]; then
      printf '%03d\n' "$1"
    elif [[ $1 =~ '^#?[[:xdigit:]]{3,}$' ]]; then
      local hex=${${${1//\#/}//ı/i}:0:6}
      printf '#%s\n' ${hex:0:$((${#hex}/3*3))}
    else
      match_color "$1"
    fi
  }
  
  
  
}

# fancy "${1:-#ff0006}"






    # local -A PRESETS=(
        # [E]='1|\Uf1398|Error' [S]='2|\uF00C|Success'
        # [W]='3|\uf421|Warning' [I]='6|\uf05a|Info'
    # )

    # hex2ansi()
    # {
        # local hex="${1//[^0-9a-f]/}"
        # hex="${hex:0:6}"

        # rgb2ansi $(printf '%d,' \
            # $(echo "$hex" | fold -w $((${#hex} / 3)) \
                # | sed -E '/^.$/s/./&&/;/^..+$/s/^/0x/')) "$2"
    # }

    # rgb2ansi()
    # {
        # local -a rgb=($(echo "$1" | grep -o '[0-9]\+'))
        # rgb+=(255 255 255)
        # local type=$((38 + ($2 * 10)))

        # printf "\e[${type};2;%d;%d;%dm" \
            # "${rgb[@]:0:3}"
    # }

    # name2ansi()
    # {
        # local -l name="${1##*-}"
        # local code="${COLORS[$name]}"
        # ansi "${code:-7}" "$2"
    # }

    # ansi()
    # {
        # local type="${2:-0}"
        # type=$((38 + (type * 10)))

        # printf "\e[${type};5;%dm" "${1//[^0-9]/}"
    # }

    # translate_color()
    # {
        # local -l arg="${1//[^a-z0-9-, \#\(\)]/}"
        # local type="${2:-0}"
        
        # if [[ "$arg" == (f|b)g-* ]]; then
            # [[ "$arg" == bg-* ]] && \
                # type=1 || type=0
            # arg="${arg#*-}"
        # fi
        
        # case "$arg" in
            # \#?[a-f0-9]*) hex2ansi "$arg" "$type" ;;
            # \(?[0-9,]*\)?) rgb2ansi "$arg" "$type" ;;
            # [0-9]*) echo ansi "$arg" "$type" ;;
            # *) name2ansi "$arg" "$type" ;;
        # esac
    # }
    
    # translate_fmts()
    # {
        # local -A defs=( b 1 d 2 i 3 u 4 )
        # local -a chars=(${(@s::)${(L)1}})
        # local -a fmts=()
        # local fmt
    
        # for c in ${(Mou)chars:#([a-z0-9])}; do
            # case "$c" in
                # [1-4]) fmts+=("$c") ;;
                # [bdiu]) fmts+=("${defs[$c]}") ;;
            # esac
        # done
        
        # fmt="${(j:;:)${fmts[@]}}"
        # [[ -n "$fmt" ]] && printf '\e[%sm' "$fmt"
    # }

    # set_title()
    # {
        # local grey="$(name2ansi 'grey42')"
        # local fgreverse="$(name2ansi 'grey15')"
        # local bgreverse="$(name2ansi 'grey15' 1)"
        # local ldome="${fgreverse}\ue0b6"
        # local lrdome="${fgreverse}\ue0b4"
        # local rdome="${FGCOLOR}\ue0b4"
        # local tbgcolor="$(ansi "${PRESET[0]}" 1)"
        
        # SPACE='  '
        # NEWLINE='\n'

        # ICON="${ldome}${bgreverse}${FGCOLOR} ${BOLD}${ICON} ${RESET}${tbgcolor}${lrdome}"
        # TITLE="${SPACE}${ICON} ${BOLD}${TITLE^}${RESET}${rdome} "
    # }

    # print()
    # {
        # printf "${NEWLINE:-}${TITLE:-}${FGCOLOR:-}${BGCOLOR:-}${FMT:-}%s${RESET}\n${NEWLINE:-}" "${1^}"
    # }
    
    # get_cfg_value() {
        # local prop="${1:-}"
        # local file="${2:-$COLORS_PROP}"
        # [[ -n "$prop" && -f "$file" ]] || return 1
    
        # command grep -m1 "^$prop=" "$file" | command cut -d= -f2-
    # }
    
    # resolve_color_vars() {
        # for p in FORE BACK; do
            # local -n var="${p[1]}GCOLOR"
            # if [[ -z "$var" ]]; then
                # local val=$(get_cfg_value "${(L)p}ground")
                # var=$(translate_color "${p[1]}g-$val")
            # fi
        # done
    # }
    
    
    
        # typeset -p
    # COLORS_PROP="$HOME/.termux/colors.properties"
    
    # BOLD='\e[1m'
    # DIM='\e[2m'
    # ITAL='\e[3m'
    # RESET='\e[0m%f%k%b' 
 
    # FGCOLOR=
    # KGCOLOR=
    # TITLE=
    # ICON=
    # SPACE=
    # NEWLINE=
    # FMT=
    # FMTS=()
    # PRESET=()
    
    # while getopts 'bdiuESWIc:f:' opt; do
        # case "$opt" in
            # b|d|i|u) FMTS+=("${DEFAULT_FMTS[$opt]}") ;;
            # E|S|W|I)
                # PRESET=($(echo "${PRESETS[$opt]}" | tr '|' '\n'))
                # set_color "${PRESET[0]}" FGCOLOR
                # ICON="${PRESET[1]}"
                # TITLE="${PRESET[2]}"
                # FMTS+=(1)
                # break
                # ;;
            # c)
                # translate_color "$OPTARG"
                # exit 0
                # ;;
            # f)
                # translate_fmts "$OPTARG"
                # exit 0
                # ;;
        # esac
    # done

    # shift $((OPTIND - 1))

    # # resolve_color_vars
    
    # [[ -z $FMT ]] && FMT=$(translate_fmts "${FMTS[*]}")
    # [[ -n $TITLE ]] && set_title

    # print "$*"
    
    
    
    
    
    