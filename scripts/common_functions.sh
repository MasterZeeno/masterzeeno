#!/data/data/com.termux/files/usr/bin/bash

termux_desktop_path="/data/data/com.termux/files/usr/etc/termux-desktop"
config_file="$termux_desktop_path/configuration.conf"
log_file="/data/data/com.termux/files/home/termux-desktop.log"

setup_git ()
{
    package_install_and_check git gh -y
    
    local USER_NAME="${1:-MasterZeeno}"
    local USER_EMAIL="${2:-zeenoliev@gmail.com}"
    local TOKEN="${3:-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}"

    git config --global user.name "$USER_NAME"
    git config --global user.email "$USER_EMAIL"
    
    gh config set -h github.com git_protocol https
    echo "$TOKEN" | gh auth login --with-token
}

print_log () 
{ 
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')";
    local log_level="${2:-INFO}";
    local message="$1";
    echo "[${timestamp}] ${log_level}: ${message}" >> "$log_file"
}
print_success ()
{
    fancy -S "$1"
    print_log "${1^}"
}
print_failed ()
{
    fancy -E "$1"
    print_log "${1^}"
}
check_termux () 
{ 
    if [[ -z "$PREFIX" && "$PREFIX" != *"/com.termux/"* ]]; then
        print_failed 'Please run it inside termux';
        exit 0;
    fi
}
wait_for_keypress () 
{ 
    read -n1 -s -r -p "${R}[${C}-${R}]${G} Press any key to continue, CTRL+c to cancel...${W}";
    echo
}
check_and_create_directory () 
{ 
    if [[ -n "$1" && ! -d "$1" ]]; then
        mkdir -p "$1";
        print_log "$1";
    fi
}
check_and_delete () 
{ 
    local file;
    local files_folders;
    for files_folders in "$@";
    do
        if [[ -n "$files_folders" ]]; then
            for file in $files_folders;
            do
                if [[ -e "$file" ]]; then
                    if [[ -d "$file" ]]; then
                        rm -rf "$file" > /dev/null 2>&1;
                    else
                        if [[ -f "$file" ]]; then
                            rm "$file" > /dev/null 2>&1;
                        fi;
                    fi;
                fi;
                print_log "$file";
            done;
        fi;
    done
}
check_and_backup () 
{ 
    local file;
    local files_folders;
    for files_folders in "$@";
    do
        if [[ -n "$files_folders" ]]; then
            for file in $files_folders;
            do
                if [[ -e "$file" ]]; then
                    local date_str;
                    date_str=$(date +"%d-%m-%Y");
                    local backup="${file}-${date_str}.bak";
                    if [[ -e "$backup" ]]; then
                        echo "${R}[${C}-${R}]${G}Backup file ${C}${backup} ${G}already exists${W}";
                        echo;
                    fi;
                    echo "${R}[${C}-${R}]${G}backing up file ${C}$file${W}";
                    mv "$1" "$backup";
                    print_log "$1 $backup";
                fi;
            done;
        fi;
    done
}
download_file () 
{ 
    local dest;
    local url;
    local max_retries=5;
    local attempt=1;
    local successful_attempt=0;
    if [[ -z "$2" ]]; then
        url="$1";
        dest="$(basename "$url")";
    else
        dest="$1";
        url="$2";
    fi;
    if [[ -z "$url" ]]; then
        print_failed "No URL provided!";
        return 1;
    fi;
    while [[ $attempt -le $max_retries ]]; do
        echo "${R}[${C}-${R}]${G} Downloading $dest...${W}";
        if [[ ! -s "$dest" ]]; then
            check_and_delete "$dest";
        fi;
        if command -v wget &> /dev/null; then
            wget --tries=5 --timeout=15 --retry-connrefused -O "$dest" "$url";
        else
            curl -# -L "$url" -o "$dest";
        fi;
        if [[ -f "$dest" && -s "$dest" ]]; then
            successful_attempt=$attempt;
            break;
        else
            print_failed "Download failed. Retrying... ($attempt/$max_retries)";
        fi;
        ((attempt++));
    done;
    if [[ -f "$dest" ]]; then
        if [[ $successful_attempt -eq 1 ]]; then
            print_success "File downloaded successfully.";
        else
            print_success "File downloaded successfully on attempt $successful_attempt.";
        fi;
        return 0;
    fi;
    print_failed "Failed to download the file after $max_retries attempts. Exiting.";
    return 1
}
check_and_restore () 
{ 
    local target_path="$1";
    local dir;
    local base_name;
    dir=$(dirname "$target_path");
    base_name=$(basename "$target_path");
    local latest_backup;
    latest_backup=$(find "$dir" -maxdepth 1 -type f -name "$base_name-[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9].bak" 2> /dev/null | sort | tail -n 1);
    if [[ -z "$latest_backup" ]]; then
        print_failed "No backup file found for ${target_path}.";
        echo;
        return 1;
    fi;
    if [[ -e "$target_path" ]]; then
        print_failed "${C}Original file or directory ${target_path} already exists.${W}";
        echo;
    else
        mv "$latest_backup" "$target_path";
        print_success "Restored ${latest_backup} to ${target_path}";
        echo;
    fi;
    print_log "$target_path $dir $base_name $latest_backup"
}
detect_package_manager () 
{ 
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
package_install_and_check () 
{ 
    print_log "Starting package installation for: $*" "INFO";
    packs_list=($@);
    for package_name in "${packs_list[@]}";
    do
        print_log "Processing package: $package_name" "DEBUG";
        echo "${R}[${C}-${R}]${G}${BOLD} Processing package: ${C}$package_name ${W}";
        if [[ "$PACKAGE_MANAGER" == "pacman" ]]; then
            if pacman -Qi "$package_name" > /dev/null 2>&1; then
                print_log "Package already installed: $package_name" "INFO";
                continue;
            fi;
            if [[ $package_name == *"*"* ]]; then
                print_log "Processing wildcard pattern: $package_name" "DEBUG";
                echo "${R}[${C}-${R}]${C} Processing wildcard pattern: $package_name ${W}";
                packages=$(pacman -Ssq "${package_name%*}" 2> /dev/null);
                for pkgs in $packages;
                do
                    echo "${R}[${C}-${R}]${G}${BOLD} Installing matched package: ${C}$pkgs ${W}";
                    pacman -Sy --noconfirm --overwrite '*' "$pkgs";
                    if [ $? -eq 0 ]; then
                        print_log "Successfully installed package: $pkgs" "INFO";
                    else
                        print_log "Failed to install package: $pkgs" "ERROR";
                    fi;
                done;
            else
                pacman -Sy --noconfirm --overwrite '*' "$package_name";
                if [ $? -eq 0 ]; then
                    print_log "Successfully installed package: $package_name" "INFO";
                else
                    print_log "Failed to install package: $package_name" "ERROR";
                fi;
            fi;
        else
            dpkg --configure -a;
            if [[ $package_name == *"*"* ]]; then
                log_debug "Processing wildcard pattern" "Pattern: $package_name";
                echo "${R}[${C}-${R}]${C} Processing wildcard pattern: $package_name ${W}";
                packages_by_name=$(apt-cache search "${package_name%*}" | awk "/^${package_name}/ {print \$1}");
                packages_by_description=$(apt-cache search "${package_name%*}" | grep -Ei "\b${package_name%*}\b" | awk '{print $1}');
                packages=$(echo -e "${packages_by_name}\n${packages_by_description}" | sort -u);
                for pkgs in $packages;
                do
                    echo "${R}[${C}-${R}]${G}${BOLD} Installing matched package: ${C}$pkgs ${W}";
                    if dpkg -s "$pkgs" > /dev/null 2>&1; then
                        log_info "Package already installed" "Package: $pkgs";
                        apt reinstall "$pkgs" -y;
                    else
                        apt install "$pkgs" -y;
                    fi;
                done;
            else
                if dpkg -s "$package_name" > /dev/null 2>&1; then
                    log_info "Package already installed" "Package: $package_name";
                    apt reinstall "$package_name" -y;
                else
                    apt install "$package_name" -y;
                fi;
            fi;
        fi;
        if [ $? -ne 0 ]; then
            log_error "Installation failed" "Package: $package_name" "Exit code: $?";
        else
            log_info "Installation successful" "Package: $package_name";
        fi;
    done;
    print_log "Package installation completed for: ${packs_list[*]}" "INFO"
}
package_check_and_remove () 
{ 
    packs_list=($@);
    for package_name in "${packs_list[@]}";
    do
        echo "${R}[${C}-${R}]${G}${BOLD} Processing package: ${C}$package_name ${W}";
        if [[ $package_name == *"*"* ]]; then
            echo "${R}[${C}-${R}]${C} Processing wildcard pattern: $package_name ${W}";
            print_log "Processing wildcard pattern: $package_name";
            if [[ "$PACKAGE_MANAGER" == "pacman" ]]; then
                packages=$(pacman -Qq | grep -E "${package_name//\*/.*}");
            else
                packages=$(dpkg --get-selections | awk '{print $1}' | grep -E "${package_name//\*/.*}");
            fi;
            for package in $packages;
            do
                echo "${R}[${C}-${R}]${G}${BOLD} Removing matched package: ${C}$package ${W}";
                if [[ "$PACKAGE_MANAGER" == "pacman" ]]; then
                    if pacman -Qi "$package" > /dev/null 2>&1; then
                        pacman -Rnds --noconfirm "$package";
                        if [ $? -eq 0 ]; then
                            print_success "$package removed successfully";
                            print_log "Processing wildcard pattern: $package_name";
                        else
                            print_failed "Failed to remove $package ${W}";
                        fi;
                    fi;
                else
                    dpkg --configure -a;
                    if dpkg -s "$pkg" > /dev/null 2>&1; then
                        apt autoremove "$pkg" -y;
                        if [ $? -eq 0 ]; then
                            print_success "$package removed successfully";
                        else
                            print_failed "Failed to remove $package ${W}";
                        fi;
                    fi;
                fi;
            done;
        else
            if [[ "$PACKAGE_MANAGER" == "pacman" ]]; then
                if pacman -Qi "$package_name" > /dev/null 2>&1; then
                    echo "${R}[${C}-${R}]${G}${BOLD} Removing package: ${C}$package_name ${W}";
                    pacman -Rnds --noconfirm "$package_name";
                    if [ $? -eq 0 ]; then
                        print_success "$package_name removed successfully";
                    else
                        print_failed "Failed to remove $package_name ${W}";
                    fi;
                fi;
            else
                dpkg --configure -a;
                if dpkg -s "$package_name" > /dev/null 2>&1; then
                    echo "${R}[${C}-${R}]${G}${BOLD} Removing package: ${C}$package_name ${W}";
                    apt autoremove "$package_name" -y;
                    if [ $? -eq 0 ]; then
                        print_success "$package_name removed successfully";
                    else
                        print_failed "Failed to remove $package_name ${W}";
                    fi;
                fi;
            fi;
        fi;
    done;
    echo "";
    print_log "$package_name"
}
get_file_name_number () 
{ 
    current_file=$(basename "$0");
    folder_name="${current_file%.sh}";
    theme_number=$(echo "$folder_name" | grep -oE '[1-9][0-9]*');
    print_log "$theme_number"
}
extract_archive () 
{ 
    local archive="$1";
    if [[ ! -f "$archive" ]]; then
        print_failed "$archive doesn't exist";
    fi;
    local total_size;
    total_size=$(stat -c '%s' "$archive");
    case "$archive" in 
        *.tar.gz | *.tgz)
            print_success "Extracting ${C}$archive";
            pv -s "$total_size" -p -r "$archive" | tar xzf - || { 
                print_failed "Failed to extract ${C}$archive";
                return 1
            }
        ;;
        *.tar.xz)
            print_success "Extracting ${C}$archive";
            pv -s "$total_size" -p -r "$archive" | tar xJf - || { 
                print_failed "Failed to extract ${C}$archive";
                return 1
            }
        ;;
        *.tar.bz2 | *.tbz2)
            print_success "Extracting ${C}$archive";
            pv -s "$total_size" -p -r "$archive" | tar xjf - || { 
                print_failed "Failed to extract ${C}$archive";
                return 1
            }
        ;;
        *.tar)
            print_success "Extracting ${C}$archive";
            pv -s "$total_size" -p -r "$archive" | tar xf - || { 
                print_failed "Failed to extract ${C}$archive";
                return 1
            }
        ;;
        *.bz2)
            print_success "Extracting ${C}$archive";
            pv -s "$total_size" -p -r "$archive" | bunzip2 > "${archive%.bz2}" || { 
                print_failed "Failed to extract ${C}$archive";
                return 1
            }
        ;;
        *.gz)
            print_success "Extracting ${C}$archive${W}";
            pv -s "$total_size" -p -r "$archive" | gunzip > "${archive%.gz}" || { 
                print_failed "Failed to extract ${C}$archive";
                return 1
            }
        ;;
        *.7z)
            print_success "Extracting ${C}$archive";
            pv -s "$total_size" -p -r "$archive" | 7z x -si -y > /dev/null || { 
                print_failed "Failed to extract ${C}$archive";
                return 1
            }
        ;;
        *.zip)
            unzip "${archive}"
        ;;
        *.rar)
            print_success "Extracting ${C}$archive";
            unrar x "$archive" || { 
                print_failed "Failed to extract ${C}$archive";
                return 1
            }
        ;;
        *)
            print_failed "Unsupported archive format: ${C}$archive";
            return 1
        ;;
    esac;
    print_success "Successfully extracted ${C}$archive";
    print_log "$archive"
}
download_and_extract () 
{ 
    local url="$1";
    local target_dir="$2";
    local filename="${url##*/}";
    cd "$target_dir" || return 1;
    if download_file "$filename" "$url"; then
        if [[ -f "$filename" ]]; then
            echo;
            echo "${R}[${C}-${R}]${R}[${C}-${R}]${G} Extracting $filename${W}";
            extract_archive "$filename";
            check_and_delete "$filename";
        fi;
    else
        print_failed "Failed to download ${C}${filename}";
        echo "${R}[${C}-${R}]${C}Please check your internet connection${W}";
    fi;
    print_log "$url $target_dir $filename"
}
count_subfolders () 
{ 
    local owner="$1";
    local repo="$2";
    local path="$3";
    local branch="$4";
    local url="https://api.github.com/repos/$owner/$repo/contents/$path?ref=$branch";
    local response;
    response=$(curl -s "$url");
    if echo "$response" | jq -e 'has("message")' > /dev/null; then
        local message;
        message=$(echo "$response" | jq -r '.message');
        if [[ "$message" == "Not Found" ]]; then
            echo 0;
            return 0;
        else
            echo "Error: $message";
            return 1;
        fi;
    fi;
    local subfolder_count;
    subfolder_count=$(echo "$response" | jq -r '[.[] | select(.type == "dir")] | length');
    if [[ -z "$subfolder_count" ]]; then
        subfolder_count=0;
    fi;
    echo "$subfolder_count"
}
confirmation_y_or_n () 
{ 
    while true; do
        read -r -p "${R}[${C}-${R}]${Y}${BOLD} $1 ${Y}(y/n) ${W}" response;
        response="${response:-y}";
        response="${response,,}";
        if [[ "$response" =~ [[:space:]/] ]]; then
            echo;
            print_failed "Invalid input: no spaces or slashes allowed. Enter only 'y' or 'n'.";
            echo;
            continue;
        fi;
        if [[ "$response" =~ ^(yes|y)$ ]]; then
            response="y";
        else
            if [[ "$response" =~ ^(no|n)$ ]]; then
                response="n";
            else
                echo;
                print_failed "Invalid input. Please enter 'y', 'yes', 'n', or 'no'.";
                echo;
                continue;
            fi;
        fi;
        eval "$2='$response'";
        case $response in 
            y)
                echo;
                print_success "Continuing with answer: $response";
                echo;
                sleep 0.2;
                break
            ;;
            n)
                echo;
                echo "${R}[${C}-${R}]${C} Skipping this step${W}";
                echo;
                sleep 0.2;
                break
            ;;
        esac;
    done;
    print_log "$1 $response"
}
get_latest_release () 
{ 
    local repo_owner="$1";
    local repo_name="$2";
    curl -s "https://api.github.com/repos/$repo_owner/$repo_name/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}
install_font_for_style () 
{ 
    local style_number="$1";
    echo "${R}[${C}-${R}]${G} Installing Fonts...${W}";
    check_and_create_directory "$HOME/.fonts";
    download_and_extract "https://raw.githubusercontent.com/sabamdarif/termux-desktop/refs/heads/setup-files/setup-files/$de_name/look_${style_number}/font.tar.gz" "$HOME/.fonts";
    fc-cache -f;
    cd "$HOME" || return 1
}
select_an_option () 
{ 
    local max_options=$1;
    local default_option=${2:-1};
    local response_var=$3;
    local response;
    while true; do
        read -r -p "${Y}select an option (Default ${default_option}): ${W}" response;
        response=${response:-$default_option};
        if [[ $response =~ ^[0-9]+$ ]] && ((response >= 1 && response <= max_options)); then
            echo;
            print_success "Continuing with answer: $response";
            sleep 0.2;
            eval "$response_var=$response";
            break;
        else
            echo;
            print_failed " Invalid input, Please enter a number between 1 and $max_options";
        fi;
    done
}
read_conf () 
{ 
    if [[ ! -f "$config_file" ]]; then
        print_failed " Configuration file $config_file not found";
        exit 0;
    fi;
    source "$config_file";
    print_success "Configuration variables loaded";
    validate_required_vars
}
print_to_config () 
{ 
    local var_name="$1";
    local var_value="${2:-${!var_name}}";
    local IFS=' 	
';
    if grep -q "^${var_name}=" "$config_file" 2> /dev/null; then
        sed -i "s|^${var_name}=.*|${var_name}=${var_value}|" "$config_file";
    else
        echo "${var_name}=${var_value}" >> "$config_file";
    fi;
    print_log "$var_name $var_value"
}
