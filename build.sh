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
    local INDEX_FSH_FILE="${ORIGINAL_DIR}/${ASSET}/index.fsh"
    local OBJECTS_COUNT=$(grep "^SHPI" "${INDEX_FSH_FILE}" | sed 's/^SHPI \([0-9][0-9]*\).*/\1/g')

    mkdir -p "${ASSET_BUILD_DIR}"

    for OBJECT_FILE_LABEL in $(grep ".BMP$" "${INDEX_FSH_FILE}" | sed 's/^[^ ]* \([^\.]*\).*/\1/g'); do
        local OBJECT_LINE_NUMBER=$(grep -n "${OBJECT_FILE_LABEL}.BMP$" "${INDEX_FSH_FILE}" | awk -F: '{print $1}')
        local SOURCE_ASSET_FILE="${SOURCE_DIR}/${ASSET}/${OBJECT_FILE_LABEL}.png"
        local ORIGINAL_ASSET_FILE="${ORIGINAL_DIR}/${ASSET}/${OBJECT_FILE_LABEL}.BMP"

        if [ -f "${SOURCE_ASSET_FILE}" ]; then
            local OBJECT_WIDTH=$(cat "${INDEX_FSH_FILE}" | head -n $((OBJECT_LINE_NUMBER+1)) | tail -n 1 | awk '{print $4}')
            local OBJECT_HEIGHT=$(cat "${INDEX_FSH_FILE}" | head -n $((OBJECT_LINE_NUMBER+1)) | tail -n 1 | awk '{print $5}')

            convert "${SOURCE_ASSET_FILE}" \
                        -resize ${OBJECT_WIDTH}x${OBJECT_HEIGHT}! \
                        -type truecolor \
                    "${ASSET_BUILD_DIR}/${OBJECT_FILE_LABEL}.BMP"
        elif [ -f "${ORIGINAL_ASSET_FILE}" ]; then
            cp "${ORIGINAL_ASSET_FILE}" "${ASSET_BUILD_DIR}/"
        else
            echo "ERROR: Cannot find ${OBJECT_FILE_LABEL} for ${ASSET} !!!"
            exit 1
        fi
    done
    
    cp "${INDEX_FSH_FILE}" "${ASSET_BUILD_DIR}/"
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
