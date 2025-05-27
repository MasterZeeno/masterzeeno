#!/data/data/com.termux/files/usr/bin/zsh

fancy() {
    (($#)) || return
    
    local -n COLORS="__p9k_colors"
    if [[ -z "${COLORS+x}" ]]; then
        source "$ZEEDIR/cache/${(P)COLORS}"
    fi
    
    local -n COLORS
    
    local -A COLORS=(
        [black]=0 [red]=1 [green]=2 [yellow]=3 [blue]=4 [magenta]=5 [cyan]=6 [white]=7 [grey]=8 [maroon]=9 [lime]=10 [olive]=11 [navy]=12 [fuchsia]=13 [aqua]=14
        [teal]=14 [silver]=15 [grey0]=16 [navyblue]=17 [darkblue]=18 [blue3]=20 [blue1]=21 [darkgreen]=22 [deepskyblue4]=25 [dodgerblue3]=26 [dodgerblue2]=27
        [green4]=28 [springgreen4]=29 [turquoise4]=30 [deepskyblue3]=32 [dodgerblue1]=33 [darkcyan]=36 [lightseagreen]=37 [deepskyblue2]=38 [deepskyblue1]=39 [green3]=40
        [springgreen3]=41 [cyan3]=43 [darkturquoise]=44 [turquoise2]=45 [green1]=46 [springgreen2]=47 [springgreen1]=48 [mediumspringgreen]=49 [cyan2]=50 [cyan1]=51
        [purple4]=55 [purple3]=56 [blueviolet]=57 [grey37]=59 [mediumpurple4]=60 [slateblue3]=62 [royalblue1]=63 [chartreuse4]=64 [paleturquoise4]=66 [steelblue]=67
        [steelblue3]=68 [cornflowerblue]=69 [darkseagreen4]=71 [cadetblue]=73 [skyblue3]=74 [chartreuse3]=76 [seagreen3]=78 [aquamarine3]=79 [mediumturquoise]=80
        [steelblue1]=81 [seagreen2]=83 [seagreen1]=85 [darkslategray2]=87 [darkred]=88 [darkmagenta]=91 [orange4]=94 [lightpink4]=95 [plum4]=96 [mediumpurple3]=98
        [slateblue1]=99 [wheat4]=101 [grey53]=102 [lightslategrey]=103 [mediumpurple]=104 [lightslateblue]=105 [yellow4]=106 [darkseagreen]=108 [lightskyblue3]=110
        [skyblue2]=111 [chartreuse2]=112 [palegreen3]=114 [darkslategray3]=116 [skyblue1]=117 [chartreuse1]=118 [lightgreen]=120 [aquamarine1]=122 [darkslategray1]=123
        [deeppink4]=125 [mediumvioletred]=126 [darkviolet]=128 [purple]=129 [mediumorchid3]=133 [mediumorchid]=134 [darkgoldenrod]=136 [rosybrown]=138 [grey63]=139
        [mediumpurple2]=140 [mediumpurple1]=141 [darkkhaki]=143 [navajowhite3]=144 [grey69]=145 [lightsteelblue3]=146 [lightsteelblue]=147 [darkolivegreen3]=149
        [darkseagreen3]=150 [lightcyan3]=152 [lightskyblue1]=153 [greenyellow]=154 [darkolivegreen2]=155 [palegreen1]=156 [darkseagreen2]=157 [paleturquoise1]=159
        [red3]=160 [deeppink3]=162 [magenta3]=164 [darkorange3]=166 [indianred]=167 [hotpink3]=168 [hotpink2]=169 [orchid]=170 [orange3]=172 [lightsalmon3]=173
        [lightpink3]=174 [pink3]=175 [plum3]=176 [violet]=177 [gold3]=178 [lightgoldenrod3]=179 [tan]=180 [mistyrose3]=181 [thistle3]=182 [plum2]=183 [yellow3]=184
        [khaki3]=185 [lightyellow3]=187 [grey84]=188 [lightsteelblue1]=189 [yellow2]=190 [darkolivegreen1]=192 [darkseagreen1]=193 [honeydew2]=194 [lightcyan1]=195
        [red1]=196 [deeppink2]=197 [deeppink1]=199 [magenta2]=200 [magenta1]=201 [orangered1]=202 [indianred1]=204 [hotpink]=206 [mediumorchid1]=207 [darkorange]=208
        [salmon1]=209 [lightcoral]=210 [palevioletred1]=211 [orchid2]=212 [orchid1]=213 [orange1]=214 [sandybrown]=215 [lightsalmon1]=216 [lightpink1]=217 [pink1]=218
        [plum1]=219 [gold1]=220 [lightgoldenrod2]=222 [navajowhite1]=223 [mistyrose1]=224 [thistle1]=225 [yellow1]=226 [lightgoldenrod1]=227 [khaki1]=228 [wheat1]=229
        [cornsilk1]=230 [grey100]=231 [grey3]=232 [grey7]=233 [grey11]=234 [grey15]=235 [grey19]=236 [grey23]=237 [grey27]=238 [grey30]=239 [grey35]=240 [grey39]=241
        [grey42]=242 [grey46]=243 [grey50]=244 [grey54]=245 [grey58]=246 [grey62]=247 [grey66]=248 [grey70]=249 [grey74]=250 [grey78]=251
        
    )
    
           

    local -A DEFAULT_FMTS=(
        [bold]=1 [b]=1
        [dim]=2 [d]=2
        [italic]=3 [i]=3
        [under]=4 [u]=4
    )

    local -A PRESETS=(
        [E]='1|\Uf1398|Error' [S]='2|\uF00C|Success'
        [W]='3|\uf421|Warning' [I]='6|\uf05a|Info'
    )

    hex2ansi()
    {
        local hex="${1//[^0-9a-f]/}"
        hex="${hex:0:6}"

        rgb2ansi $(printf '%d,' \
            $(echo "$hex" | fold -w $((${#hex} / 3)) \
                | sed -E '/^.$/s/./&&/;/^..+$/s/^/0x/')) "$2"
    }

    rgb2ansi()
    {
        local -a rgb=($(echo "$1" | grep -o '[0-9]\+'))
        rgb+=(255 255 255)
        local type=$((38 + ($2 * 10)))

        printf "\e[${type};2;%d;%d;%dm" \
            "${rgb[@]:0:3}"
    }

    name2ansi()
    {
        local -l name="${1##*-}"
        local code="${COLORS[$name]}"
        ansi "${code:-7}" "$2"
    }

    ansi()
    {
        local type="${2:-0}"
        type=$((38 + (type * 10)))

        printf "\e[${type};5;%dm" "${1//[^0-9]/}"
    }

    translate_color()
    {
        local -l arg="${1//[^a-z0-9-, \#\(\)]/}"
        local type="${2:-0}"
        
        if [[ "$arg" == (f|b)g-* ]]; then
            [[ "$arg" == bg-* ]] && \
                type=1 || type=0
            arg="${arg#*-}"
        fi
        
        case "$arg" in
            \#?[a-f0-9]*) hex2ansi "$arg" "$type" ;;
            \(?[0-9,]*\)?) rgb2ansi "$arg" "$type" ;;
            [0-9]*) echo ansi "$arg" "$type" ;;
            *) name2ansi "$arg" "$type" ;;
        esac
    }
    
    _p9k_translate_color() {
      if [[ $1 == <-> ]]; then                  # decimal color code: 255
        _p9k__ret=${(l.3..0.)1}
      elif [[ $1 == '#'[[:xdigit:]]## ]]; then  # hexadecimal color code: #ffffff
        _p9k__ret=${${(L)1}//ı/i}
      else                                      # named color: red
        # Strip prifixes if there are any.
        _p9k__ret=$__p9k_colors[${${${1#bg-}#fg-}#br}]
      fi
    }

    translate_fmts()
    {
        local -A defs=( b 1 d 2 i 3 u 4 )
        local -a chars=(${(@s::)${(L)1}})
        local -a fmts=()
        local fmt
    
        for c in ${(Mou)chars:#([a-z0-9])}; do
            case "$c" in
                [1-4]) fmts+=("$c") ;;
                [bdiu]) fmts+=("${defs[$c]}") ;;
            esac
        done
        
        fmt="${(j:;:)${fmts[@]}}"
        [[ -n "$fmt" ]] && printf '\e[%sm' "$fmt"
    }

    set_title()
    {
        local grey="$(name2ansi 'grey42')"
        local fgreverse="$(name2ansi 'grey15')"
        local bgreverse="$(name2ansi 'grey15' 1)"
        local ldome="${fgreverse}\ue0b6"
        local lrdome="${fgreverse}\ue0b4"
        local rdome="${FGCOLOR}\ue0b4"
        local tbgcolor="$(ansi "${PRESET[0]}" 1)"
        
        SPACE='  '
        NEWLINE='\n'

        ICON="${ldome}${bgreverse}${FGCOLOR} ${BOLD}${ICON} ${RESET}${tbgcolor}${lrdome}"
        TITLE="${SPACE}${ICON} ${BOLD}${TITLE^}${RESET}${rdome} "
    }

    print()
    {
        printf "${NEWLINE:-}${TITLE:-}${FGCOLOR:-}${BGCOLOR:-}${FMT:-}%s${RESET}\n${NEWLINE:-}" "${1^}"
    }
    
    get_cfg_value() {
        local prop="${1:-}"
        local file="${2:-$COLORS_PROP}"
        [[ -n "$prop" && -f "$file" ]] || return 1
    
        command grep -m1 "^$prop=" "$file" | command cut -d= -f2-
    }
    
    resolve_color_vars() {
        for p in FORE BACK; do
            local -n var="${p[1]}GCOLOR"
            if [[ -z "$var" ]]; then
                local val=$(get_cfg_value "${(L)p}ground")
                var=$(translate_color "${p[1]}g-$val")
            fi
        done
    }
    
    COLORS_PROP="$HOME/.termux/colors.properties"
    
    BOLD='\e[1m'
    DIM='\e[2m'
    ITAL='\e[3m'
    RESET='\e[0m%f%k' 
 
    FGCOLOR=
    BGCOLOR=
    TITLE=
    ICON=
    SPACE=
    NEWLINE=
    FMT=
    FMTS=()
    PRESET=()
    
    while (($#)); do
        case "$1" in
            -fg=* | --foreground=*) FGCOLOR=$(translate_color "${1##*=}") ;;
            -bg=* | --background=*) BGCOLOR=$(translate_color "${1##*=}" 1) ;;
            -fmt=* | --formats=*) FMT=$(translate_fmts "$1") ;;
            *) break ;;
        esac
        shift
    done

    while getopts 'bdiuESWIc:f:' opt; do
        case "$opt" in
            b | d | i | u) FMTS+=("${DEFAULT_FMTS[$opt]}") ;;
            E | S | W | I)
                PRESET=($(echo "${PRESETS[$opt]}" | tr '|' '\n'))
                FGCOLOR=$(ansi "${PRESET[0]}")
                ICON="${PRESET[1]}"
                TITLE="${PRESET[2]}"
                FMTS+=(1)
                break
                ;;
            c)
                translate_color "$OPTARG"
                exit 0
                ;;
            f)
                translate_fmts "$OPTARG"
                exit 0
                ;;
        esac
    done

    shift $((OPTIND - 1))

    resolve_color_vars
    
    [[ -z $FMT ]] && FMT=$(translate_fmts "${FMTS[*]}")
    [[ -n $TITLE ]] && set_title

    print "$*"
}
