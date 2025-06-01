(return 0 2>/dev/null) || exit 0

[ -n "${BASH_VERSION:-}" ] || [ -n "${ZSH_VERSION:-}" ] || return 0
trap 'unset x; return 0' EXIT

{
  x() { while [ $# -ge 2 ]; do typeset -grxH "USER_$1=$2"; shift 2; done; }
  
  x 'ID' '15913' 'ALIAS' 'zee' 'NAME' 'MasterZeeno' \
    'REAL_NAME' 'Jay Ar Adlaon Cimacio, RN, OHN, DM II' \
    'TOKEN' 'VGxcSUkc1rNXFRmVFZPVkVirMVEyoYzlQUaWi89Cg' \
    'EMAIL' 'masterzeeno@outlook.com' 'ALT' 'Zeeno Liev Cimacio'
    
} &>/dev/null
