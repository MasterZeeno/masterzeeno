#!/data/data/com.termux/files/usr/bin/zsh


"https://raw.githubusercontent.com/romkatv/powerlevel10k/refs/heads/master/internal/p10k.zsh" 

test() {
    local var='__p9k_colors'
    if [[ -z "${(P)var}" ]]; then
        local file="$ZEEDIR/cache/$var"
        if [[ ! -s "$file" ]]; then
            curl -s "https://raw.githubusercontent.com/romkatv/powerlevel10k/refs/heads/master/internal/p10k.zsh" | \
                sed -n "/^typeset.*$var=(/,/)/p" > "$file"
        fi
        source "$file"
    fi
    echo "${(P)var}"
}

test