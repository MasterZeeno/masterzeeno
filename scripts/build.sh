#!/usr/bin/env bash

[ -z "${BASH_VERSION:-}" ] && exit 1
(return 0 2>/dev/null) && exit 1

fetch() {
  local url="${1:?}" && shift
  local -a flags=("$@")
  local -a cflags=(
    --fail --location --retry-connrefused --styled-output --progress-bar
    --retry 5 --retry-delay 5 --connect-timeout 30 --retry-max-time 120 
    --speed-limit 1000 --speed-time 60
  )
  curl "${cflags[@]}" "${flags[@]}" "$url"
}

finder() {
  local dir="${1:?}"
  mkdir -p "$dir" || return 1
  
  find -P "$dir" -mindepth 1 -type "${3:-d}" -iname "${2:-*}" -print -quit
}

latest_zip() {
  fetch "$ANDROID_HOMEURL/${1:?}" --silent \
    | grep -Eoim1 "${2:?}.*${PLATFORM}.*\.zip"
}

sticky_export() {
  local var="${1:?}"
  local val="'${2:?}'"
  
  if ! grep -q "export ${var}=${val}" "$SHELLRC"; then
    sed -Ei "/^.*export ${var}=/d" "$SHELLRC"
    echo "export ${var}=${val}" >> "$SHELLRC"
    export "${var}=${val}"
  fi
}

SHELLRC="$HOME/.${SHELL##*/}rc"
ANDROID_TOOLS_ROOT="$HOME/.android"
TMPDIR="${TMPDIR:-$HOME/.tmp}"

PLATFORM=$(uname -s)
SDK_REVISION=9123335
NDK_REVISION=r27c
TOOLS_VERSION=33.0.1

[[ "$1" == "-f" || "$1" == "--force" ]] && \
  rm -rf "$ANDROID_TOOLS_ROOT"

mkdir -p "$ANDROID_TOOLS_ROOT" "$TMPDIR" || exit 1

ANDROID_HOMEURL="https://developer.android.com"
ANDROID_REPOURL="https://dl.google.com/android/repository"

for VAR in SDK NDK; do
  [[ ! -v "$VAR" || ! -e "${!VAR}" || \
    -z "$(finder "$ANDROID_TOOLS_ROOT")" ]] || continue
  
  TOOLPATH="$ANDROID_TOOLS_ROOT/android-${VAR,,}"
  mkdir -p "$TOOLPATH" || exit 1

  if [[ "$VAR" == 'NDK' ]]; then
    FILENAME="android-ndk-${NDK_REVISION}-${PLATFORM,,}"
  else
    FILENAME="commandlinetools-${PLATFORM,,}-${SDK_REVISION}_latest"
  fi
  
  OUTPUTFILE="${TMPDIR}/${FILENAME}.zip"; RETRIES=0
  
  while [[ ! -s "$OUTPUTFILE" ]]; do
    fetch "$ANDROID_REPOURL/${FILENAME}.zip" --output "$OUTPUTFILE"
    ((RETRIES++)); ((RETRIES>3)) && return 1
  done
  
  unzip -oq "$OUTPUTFILE" -d "$TOOLPATH"
  TOOLDIR=$(finder "$TOOLPATH")
  
  if [[ "$VAR" == "NDK" ]]; then
    mv -f "$TOOLDIR"/* "$TOOLPATH"/
    rm -rf "$TOOLDIR" "$(finder "$TOOLPATH/sources" 'system')"
  else
    mkdir -p "$TOOLPATH/latest"
    mv -f "$TOOLDIR"/* "$TOOLPATH/latest"/
    mv -f "$TOOLPATH/latest" "$TOOLDIR"/
  fi
  
  printf '%s\n' {'ANDROID_',}"${VAR}"{'_ROOT',} \
    | while IFS= read -r XVAR; do
      sticky_export "$XVAR" "$TOOLPATH"
    done
done

sticky_export "ANDROID_HOME" "$ANDROID_SDK_ROOT"
SDK_MANAGER=$(finder "$ANDROID_HOME" 'sdkmanager' f)

[[ -x "$SDK_MANAGER" ]] || \
  { echo "'sdkmanager' no execute permissions or not found"; exit 1; }

yes | "$SDK_MANAGER" \
  --sdk_root="$ANDROID_HOME" \
  --licenses

yes | "$SDK_MANAGER" \
  --sdk_root="$ANDROID_HOME" \
  "platform-tools" \
  "build-tools;${TOOLS_VERSION}" \
  "platforms;android-"{24,28,35}
  
