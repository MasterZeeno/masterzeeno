#!/usr/bin/env bash

fetch() {
	local type=${1:?}
	local url=${2:?}

	[[ "$url" =~ ^https://(/[^/]+)+$ ]] || url=https://${url}

	local -a opts=(
		--fail               # Consider 4xx and 5xx responses as failures
		--retry 5            # Retry up to 5 times on transient failures
		--retry-connrefused  # Also retry on refused connections
		--retry-delay 5      # Wait 5 seconds between retries
		--connect-timeout 30 # Wait at most 30 seconds for a connection to be established
		--retry-max-time 120 # Stop retrying if it's still failing after 120 seconds
		--speed-limit 1000   # Expect at least 1000 Bytes per second
		--speed-time 60      # Fail if the minimum speed isn't met for at least 60 seconds
		--location           # Follow redirects
		--silent
	)

	curl ${opts[@]} ${url} | \
	{
		case "$type" in
			-s) sha256sum | awk '{print $1}' ;;
			-v) jq -r '.[0].name' | sed 's/^[vV]//' ;;
		esac
	}
}

REPO_OWNER=MasterZeeno
REPO_EMAIL=${REPO_OWNER,,}@outlook.com
REPO_NAME=fancy
REPO=${REPO_OWNER}/${REPO_NAME}
DOMAIN=github.com
TAGS_URL=https://api.${DOMAIN}/repos/${REPO}/tags

TERMUX_PKG_HOMEPAGE=https://${DOMAIN}/${REPO}
TERMUX_PKG_DESCRIPTION="A command-line tool to generate, analyze, convert and manipulate colors"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_LICENSE_FILE="LICENSE-MIT, LICENSE-APACHE"
TERMUX_PKG_MAINTAINER="${REPO_OWNER} <${REPO_EMAIL}>"
TERMUX_PKG_VERSION=$(fetch -v "${TAGS_URL}")
TERMUX_PKG_SRCURL=${TERMUX_PKG_HOMEPAGE}/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=$(fetch -s ${TERMUX_PKG_SRCURL})
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	termux_setup_rust
}

termux_step_make() {
	SHELL_COMPLETIONS_DIR=$TERMUX_PKG_BUILDDIR/completions cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release
}

termux_step_make_install() {
	local -A SHELLS=(
		[zsh]="/site-functions"
		[bash]="-completion/completions"
		[fish]="/vendor_completions.d"
	)

	install -Dm755 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/${REPO_NAME}

	# Install completions
	for SHELL in "${!SHELLS[@]}"; do
		local FILE="${REPO_NAME}.${SHELL}"
		[[ "$SHELL" == "zsh" ]] && FILE="_${REPO_NAME}"

		install -Dm600 $TERMUX_PKG_BUILDDIR/completions/_${FILE} \
			$TERMUX_PREFIX/share/${SHELL}${SHELLS[$SHELL]}/${FILE}
	done

	# install -Dm600 $TERMUX_PKG_BUILDDIR/completions/_${REPO_NAME} \
	# 	$TERMUX_PREFIX/share/zsh/site-functions/_${REPO_NAME}
	# install -Dm600 $TERMUX_PKG_BUILDDIR/completions/${REPO_NAME}.bash \
	# 	$TERMUX_PREFIX/share/bash-completion/completions/${REPO_NAME}.bash
	# install -Dm600 $TERMUX_PKG_BUILDDIR/completions/${REPO_NAME}.fish \
	# 	$TERMUX_PREFIX/share/fish/vendor_completions.d/${REPO_NAME}.fish
}
