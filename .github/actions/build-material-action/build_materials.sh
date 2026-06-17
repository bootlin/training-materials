#!/bin/sh
set -ex

git config --global --add safe.directory $GITHUB_WORKSPACE
make -j$(nproc) $*
