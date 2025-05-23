#!/usr/bin/env sh

gh config set -h github.com git_protocol https
echo "${1:?}" | gh auth login --with-token