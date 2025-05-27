cmd_exists() {
    command -v "$1" >/dev/null 2>&1
}
print_success() {
    fancy -S "$1"
    print_log "${1^}"
}
print_failed() {
    fancy -E "$1"
    print_log "${1^}"
}
# Returns the full path of a command if found
bin_path() {
  command -v "$1" 2>/dev/null
}
# Sources a file either by direct path or by resolving it via `command -v`
source_file() {
  # Exit if no argument is passed
  (( $# )) || return 1

  local file candidate

  for candidate in "$1" "$(bin_path "$1")"; do
    [[ -f "$candidate" && -r "$candidate" ]] && {
      file=$candidate
      break
    }
  done

  [[ -n "$file" ]] && builtin source "$file"
}
detect_package_manager() { 
    source "/data/data/com.termux/files/usr/bin/termux-setup-package-manager";
    if [[ "$TERMUX_APP_PACKAGE_MANAGER" == "apt" ]]; then
        PACKAGE_MANAGER="apt";
    else
        if [[ "$TERMUX_APP_PACKAGE_MANAGER" == "pacman" ]]; then
            PACKAGE_MANAGER="pacman";
        else
            print_failed "${C} Could not detact your package manager, Switching To ${C}pkg ${W}";
        fi;
    fi;
    print_log "$PACKAGE_MANAGER"
}
package_install_and_check() {
  print_log "Starting package installation for: $*" "INFO"
  local packs_list=("$@")

  for package_name in "${packs_list[@]}"; do
    print_log "Processing package: $package_name" "DEBUG"
    echo "${R}[${C}-${R}]${G}${BOLD} Processing package: ${C}$package_name ${W}"

    if [[ "$PACKAGE_MANAGER" == "pacman" ]]; then
      if pacman -Qi "$package_name" > /dev/null 2>&1; then
        print_log "Package already installed: $package_name" "INFO"
        continue
      fi

      if [[ "$package_name" == *"*"* ]]; then
        print_log "Processing wildcard pattern: $package_name" "DEBUG"
        echo "${R}[${C}-${R}]${C} Processing wildcard pattern: $package_name ${W}"
        local packages=("${(@f)$(pacman -Ssq "${package_name%*}" 2>/dev/null)}")
        for pkgs in "${packages[@]}"; do
          echo "${R}[${C}-${R}]${G}${BOLD} Installing matched package: ${C}$pkgs ${W}"
          pacman -Sy --noconfirm --overwrite '*' "$pkgs"
          [[ $? -eq 0 ]] && print_log "Successfully installed package: $pkgs" "INFO" || print_log "Failed to install package: $pkgs" "ERROR"
        done
      else
        pacman -Sy --noconfirm --overwrite '*' "$package_name"
        [[ $? -eq 0 ]] && print_log "Successfully installed package: $package_name" "INFO" || print_log "Failed to install package: $package_name" "ERROR"
      fi

    else
      dpkg --configure -a

      if [[ "$package_name" == *"*"* ]]; then
        log_debug "Processing wildcard pattern" "Pattern: $package_name"
        echo "${R}[${C}-${R}]${C} Processing wildcard pattern: $package_name ${W}"
        local packages_by_name=("${(@f)$(apt-cache search "${package_name%*}" | awk "/^${package_name}/ {print \$1}")}")
        local packages_by_description=("${(@f)$(apt-cache search "${package_name%*}" | grep -Ei "\b${package_name%*}\b" | awk '{print $1}')}")
        local packages=("${(@u)${(f)packages_by_name}${(f)packages_by_description}}")

        for pkgs in "${packages[@]}"; do
          echo "${R}[${C}-${R}]${G}${BOLD} Installing matched package: ${C}$pkgs ${W}"
          if dpkg -s "$pkgs" > /dev/null 2>&1; then
            log_info "Package already installed" "Package: $pkgs"
            apt reinstall "$pkgs" -y
          else
            apt install "$pkgs" -y
          fi
        done
      else
        if dpkg -s "$package_name" > /dev/null 2>&1; then
          log_info "Package already installed" "Package: $package_name"
          apt reinstall "$package_name" -y
        else
          apt install "$package_name" -y
        fi
      fi
    fi

    if [[ $? -ne 0 ]]; then
      log_error "Installation failed" "Package: $package_name" "Exit code: $?"
    else
      log_info "Installation successful" "Package: $package_name"
    fi
  done

  print_log "Package installation completed for: ${(j:, :)packs_list}" "INFO"
}