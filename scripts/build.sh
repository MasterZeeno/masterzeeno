if [ "$(uname -o)" != "Android" ] && [ "$TERMUX_PREFIX" != *"com.termux"* ]; then
  if ! command -v rustup &>/dev/null; then
    SUDO="sudo"
    if [ "$(id -u)" = "0" ]; then
      SUDO=""
    fi
    if command -v apt-get &>/dev/null; then
      $SUDO apt-get -yq update
      $SUDO env DEBIAN_FRONTEND=noninteractive \
        apt-get install -yq --no-install-recommends rustup
    elif command -v pacman &>/dev/null; then
      $SUDO pacman -Syq --needed --noconfirm rustup
    fi

    if [ $? -eq 1 ]; then
      curl --proto '=https' --tlsv1.2 --retry 10 \
        --retry-connrefused --location --silent --show-error \
        --fail https://sh.rustup.rs | sh -s -- --default-toolchain none -y
    fi

    . $HOME/.cargo/env || return 1
  fi
fi

_fc() {
  s="${1:?}" i="${2:-}"
  case "$i" in
    0) echo "$s" | \
      tr '[:upper:]' '[:lower:]'
      return ;;
    [0-9]*) ;; *) i=${#s} ;;
  esac
  echo "$s" | sed -E "s/^(.{0,$i})/\U\1/"
  unset s i
}

_DIST_REPO_OWNER='MasterZeeno'
_DIST_REPO_NAME='fancy'
_SRC_REPO_OWNER='sharkdp'
_SRC_REPO_NAME='pastel'
_SRC_REPO="https://github.com/${_SRC_REPO_OWNER}/${_SRC_REPO_NAME}"
_SRC_TOML_URL="https://raw.githubusercontent.com/${_SRC_REPO_OWNER}/${_SRC_REPO_NAME}/refs/heads/master/Cargo.toml"
_SRC_TOML="${TMPDIR}/$(basename "${_SRC_TOML_URL}")"
while [ ! -s "${_SRC_TOML}" ]; do curl -sL -o "${_SRC_TOML}" "${_SRC_TOML_URL}"; done
for j in description version license author; do case "$j" in author) q="${j}s[0]"; j=$(_fc "_SRC_${j}") ;; *) q="$j"; j=$(_fc "TERMUX_PKG_${j}") ;; esac
eval $(cargo metadata --format-version 1 --no-deps --manifest-path="${_SRC_TOML}" | jq -r ".packages[0] | \"${j}='\(.${q})'\""); done; unset j q; rm -rf "${_SRC_TOML}"

TERMUX_PKG_HOMEPAGE="https://github.com/${_DIST_REPO_OWNER}/${_DIST_REPO_NAME}"
TERMUX_PKG_LICENSE_FILE=$(_fc "${TERMUX_PKG_LICENSE%-*}" | sed 's|[^/]*|LICENSE-&|g;s|/|, |g')
TERMUX_PKG_LICENSE="${TERMUX_PKG_LICENSE%/*}"
TERMUX_PKG_MAINTAINER="${_DIST_REPO_OWNER} $(_fc "<${_DIST_REPO_OWNER}@outlook.com>" 0)"
TERMUX_PKG_SRCURL="${_SRC_REPO}/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=$(curl -sL ${TERMUX_PKG_SRCURL} | sha256sum | awk '{print $1}')
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
  find -P "$TERMUX_PKG_SRCDIR" -mindepth 1 \
    | while IFS= read -r _ITEM; do
      [ -w "$_ITEM" ] || continue
      for v in _REPO_{OWNER,NAME}; do
        for p in _{SRC,DIST}; do eval "${p}=\$${p}${v}"; done
        for i in 0 1 -; do _SRCR=$(_fc "${_SRC}" $i)
          case "$v" in *OWNER*) _DISTR="${_DIST}" ;; *) _DISTR=$(_fc "${_DIST}" $i) ;; esac
          if [ -f "${_ITEM}" ]; then
            grep -q "${_SRCR}" "${_ITEM}" && sed -i "s/${_SRCR}/${_DISTR}/g" "${_ITEM}"
            grep -q "${_SRC_AUTHOR}" "${_ITEM}" && sed -i "s/${_SRC_AUTHOR}/${TERMUX_PKG_MAINTAINER}/g" "${_ITEM}" 
          fi
          case "$_ITEM" in *$_SRCR*) mv -f "$_ITEM" "${_ITEM//$_SRCR/$_DISTR}" ;; esac
        done
      done
    done
  unset _SRC _DIST _SRCR _DISTR _ITEM
  termux_setup_rust
}

termux_step_make() {
  SHELL_COMPLETIONS_DIR="$TERMUX_PKG_BUILDDIR/completions" \
    cargo build \
      --jobs "$TERMUX_PKG_MAKE_PROCESSES" \
      --target "$CARGO_TARGET_NAME" \
      --release
}

termux_step_make_install() {
  declare -A _SHELLS=(
    ['z']='/site-functions'
    ['ba']='-completion/completions'
    ['fi']='/vendor_completions.d'
  )

  install -Dm755 -t \
    "$TERMUX_PREFIX/bin" \
    "target/${CARGO_TARGET_NAME}/release/${_DIST_REPO_NAME}"
  
  for _SHELL in "${!_SHELLS[@]}"; do 
    case "$_SHELL" in
      z) _FILE="_${_DIST_REPO_NAME}" ;;
      *) _FILE="${_DIST_REPO_NAME}.${_SHELL}sh" ;;
    esac 
    install -Dm600 \
      "$TERMUX_PKG_BUILDDIR/completions/${_FILE}" \
      "$TERMUX_PREFIX/share/${_SHELL}sh${_SHELLS[$_SHELL]}/${_FILE}"
  done
  
  unset _SHELLS _SHELL _FILE
}
