#!/bin/sh
trap 'rm -rf "${ROOTPATH_TMP}" "${GENIMAGE_TMP}"' EXIT
ROOTPATH_TMP="$(mktemp -d)"
GENIMAGE_TMP="$(mktemp -d)"
genimage \
        --rootpath "${ROOTPATH_TMP}"     \
        --tmppath "${GENIMAGE_TMP}"    \
        --inputpath .  \
        --outputpath . \
        --config genimage.cfg
