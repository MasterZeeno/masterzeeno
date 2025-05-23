#!/usr/bin/env bash

gh config set -h github.com git_protocol https
echo "${1:?}" | gh auth login --with-token