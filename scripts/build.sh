#!/usr/bin/env bash

# Exit immediately if not sourced
(return 0 2>/dev/null) || exit 1

BUILD_TOOLS_PATH="$HOME/.android/build-tools"
rm -rf "$BUILD_TOOLS_PATH"
mkdir -p "$BUILD_TOOLS_PATH"

unset ANDROID_HOME NDK

for VAR in ANDROID_HOME NDK; do
  [[ -n "${!VAR}" ]] && continue  # Skip if variable is already set

  url="https://developer.android.com/"
  tool_path="$BUILD_TOOLS_PATH/android-"

  if [[ "$VAR" == "NDK" ]]; then
    url+="ndk/downloads"
    locator="android-ndk"
    tool_path+="ndk"
  else
    url+="studio#command-tools"
    locator="commandlinetools"
    tool_path+="sdk"
  fi

  zip_file=$(curl -s "$url" | grep -Eoim1 \
    "${locator}.*linux.*\.zip")
    
  [[ -z "$zip_file" ]] && \
    { echo "Failed to locate $locator zip"; return 1; }

  curl \
    --fail \
    --retry 5 \
    --retry-connrefused \
    --retry-delay 5 \
    --connect-timeout 30 \
    --retry-max-time 120 \
    --speed-limit 1000 \
    --speed-time 60 \
    --location \
    --output "${tool_path}.zip" \
    "https://dl.google.com/android/repository/${zip_file}"

  [[ -f "$zip_path" ]] || \
    { echo "Download failed for $zip_path"; return 1; }

  mkdir -p "$tool_path"
  unzip -q "${tool_path}.zip" -d "$tool_path"
  rm -rf "${tool_path}.zip" "${tool_path}/sources/cxx-stl/system"

  export "$VAR=$tool_path"

  if ! grep -q "export $VAR=" "$HOME/.bashrc"; then
    echo "export $VAR=$tool_path" >> "$HOME/.bashrc"
  fi
done

# Locate sdkmanager binary
SDK_MANAGER=$(find "$ANDROID_HOME/cmdline-tools" \
  -type f -name 'sdkmanager' | head -n1)

[[ -z "$SDK_MANAGER" ]] && \
  { echo "sdkmanager not found"; return 1; }

yes | "$SDK_MANAGER" \
  --sdk_root="$ANDROID_HOME" \
  --licenses

yes | "$SDK_MANAGER" \
  --sdk_root="$ANDROID_HOME" \
	"platform-tools" \
	"build-tools;33.0.1" \
	"platforms;android-"{35,28,24}
