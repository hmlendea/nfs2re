#!/bin/bash

SOURCE_DIR="src"
BUILD_DIR="build"
OUTPUT_DIR="out"
ORIGINAL_DIR="original"
GAME_DIR="/opt/nfs2se"

FSHTOOL="${OUTPUT_DIR}/tools/fshtool"

[ -d "${OUTPUT_DIR}/tools" ] || mkdir -p "${OUTPUT_DIR}/tools"
[ -d "${OUTPUT_DIR}/fedata/pc/art/slides" ] || mkdir -p "${OUTPUT_DIR}/fedata/pc/art/slides"

gcc "src/tools/fshtool.c" -o "${OUTPUT_DIR}/tools/fshtool"

function extract_qfs() {
    local FILE_PATH="${*}"
    local FILE_DIR="$(dirname ${FILE_PATH})"
    local FILE_NAME="$(basename ${ASSET})"

    yes | "${FSHTOOL}" "${FILE_PATH}" "${FILE_DIR}/${FILE_NAME}"
}

function extract_original_qfs() {
    local ASSET="${*}"
    local ASSET_DIR="$(dirname ${ASSET})"
    local ASSET_NAME="$(basename ${ASSET})"
    local TARGET_DIR="${ORIGINAL_DIR}/${ASSET_DIR}"
    local TARGET_FILE="${TARGET_DIR}/${ASSET_NAME}.qfs"

    mkdir -p "${TARGET_DIR}"
    cp "${GAME_DIR}/${ASSET}.qfs" "${TARGET_FILE}"
    extract_qfs "${TARGET_FILE}"
}

function prepare_asset_build_dir() {
    local ASSET="${*}"
    local ASSET_BUILD_DIR="${BUILD_DIR}/${ASSET}"

    mkdir -p "${ASSET_BUILD_DIR}"
    cp "${ORIGINAL_DIR}/${ASSET}/"*.* "${ASSET_BUILD_DIR}/"
    cp -f "${SOURCE_DIR}/realistic/${ASSET}/"*.* "${ASSET_BUILD_DIR}/"
}

function build_qfs() {
    local ASSET="${*}"
    local ASSET_DIR="$(dirname ${ASSET})"

    [ ! -d "${ORIGINAL_DIR}/${ASSET}" ] && extract_original_qfs "${ASSET}"

    prepare_asset_build_dir "${ASSET}"

    echo "Building ${ASSET}..."
    mkdir -p "${OUTPUT_DIR}/${ASSET_DIR}"
    yes | "${FSHTOOL}" "${BUILD_DIR}/${ASSET}/index.fsh" "${OUTPUT_DIR}/${ASSET}.qfs"
}

build_qfs "gamedata/tracks/se/tr000"
