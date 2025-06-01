#!/bin/zsh

# match_color() {
  # local match query="${${(L)1#*-}//[^a-z0-9]/}"
  
  # for ((n=${#query}; n>=$((${#query}/2)); n--)); do
    # query="${query:0:$n}"
    # match=$(print -l ${(k)__p9k_colors} | \
      # grep -i "^$query" | sort | head -n1)
    # [[ -n "$match" ]] && break
  # done

  # echo "$match"
# }

# match_color() {
  # local -l sub match query="${${(L)1#*-}//[^a-z0-9]/}"
  # local -U keys=(${(k)__p9k_colors})

  # for ((n=${#query}; n>=${#query}/2; n--)); do
    # sub="${query:0:$n}"
    # match=$(print -l $keys | grep -i \
      # "^$sub" | sort -su | head -n1)
    # [[ -n "$match" ]] && break
  # done

  # echo "$match"
# }

# match_color "${1:-pink}"

# test() {
  # local s="$1"
  # for i in {${#s}..1}; do
    # echo "${s:0:$i}"
  # done
# }

# test "yawakaanimal"


# Decimal to Hex
to_hex() { printf '%x\n' $((10#$1)); }

# Decimal to Octal
to_oct() { printf '%o\n' $((10#$1)); }

# Decimal to Binary
to_bin() {
  local bin dec=$((10#$1))
  while (( dec )); do
    bin=$((dec % 2))$bin
    ((dec /= 2))
  done
  echo ${bin:-0}
}

# Hex to Decimal
from_hex() { echo $((16#$1)); }

# Octal to Decimal
from_oct() { echo $((8#$1)); }

# Binary to Decimal
from_bin() { echo $((2#$1)); }

to_hex 255     # ff
to_bin 10      # 1010
from_hex ff    # 255
from_bin 1101  # 13
to_oct 64      # 100
