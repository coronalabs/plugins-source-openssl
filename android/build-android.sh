#!/bin/bash

# build OpenSSL 3.0.8 with NDK r18b, April 2023

set -ex

# check OUTPUT_DIR
OUTPUT_DIR=${OUTPUT_DIR:=./build_android_openssl}
mkdir -p "${OUTPUT_DIR}"
# OpenSSL Configure needs absolute path
OUTPUT_DIR=$(realpath $OUTPUT_DIR)

# tested with OpenSSL 3.0.8
OPENSSL_VERSION=${OPENSSL_VERSION:-"openssl-3.0.8"}
if [ ! -f "${OUTPUT_DIR}/${OPENSSL_VERSION}.tar.gz" ]; then
    curl -L "https://github.com/openssl/openssl/releases/download/${OPENSSL_VERSION}/${OPENSSL_VERSION}.tar.gz" -o "${OUTPUT_DIR}/${OPENSSL_VERSION}.tar.gz";
fi
tar -xf "${OUTPUT_DIR}/${OPENSSL_VERSION}.tar.gz" --directory "${OUTPUT_DIR}"
cd "${OUTPUT_DIR}/${OPENSSL_VERSION}"

# make JOBS, tested on macOS
JOBS=$(sysctl -n hw.ncpu)
JOBS=${JOBS:=1}

# tested with NDK r18b
NDK_HOSTNAME=${NDK_HOSTNAME:=darwin-x86_64}
ANDROID_NDK=${ANDROID_NDK:?"Config NDK first"}
ANDROID_NDK_ROOT=${ANDROID_NDK}
PATH=${ANDROID_NDK}/toolchains/llvm/prebuilt/${NDK_HOSTNAME}/bin:${PATH}

build() {
    TARGET=${1:?"Specify one of android-arm, android-x86, android-arm64, android-x86_64 as target"}
	  ANDROID_API=${2:?"Specify Android API level (number)"}
    ANDROID_ABI=${3:?"Specify Android ABI name"}

    make -j${JOBS} clean || true

    # Build openssl libraries
    ./Configure "${TARGET}" -D__ANDROID_API__="${ANDROID_API}" \
        -D_REENTRANT threads no-shared \
        --prefix="${OUTPUT_DIR}/builds/${TARGET}-${ANDROID_API}" --openssldir="${OUTPUT_DIR}/builds/${TARGET}-${ANDROID_API}"

    make -j${JOBS} clean
    make -j${JOBS} build_sw
    make -j${JOBS} install_sw

    mkdir -p "${OUTPUT_DIR}/../lib/includes/${ANDROID_ABI}/"
    cp -r "${OUTPUT_DIR}/builds/${TARGET}-${ANDROID_API}/include/openssl" "${OUTPUT_DIR}/../lib/includes/${ANDROID_ABI}/"
    mkdir -p "${OUTPUT_DIR}/../lib/libs/${ANDROID_ABI}/"
    cp "${OUTPUT_DIR}/builds/${TARGET}-${ANDROID_API}/lib/libcrypto.a" "${OUTPUT_DIR}/../lib/libs/${ANDROID_ABI}/"
    cp "${OUTPUT_DIR}/builds/${TARGET}-${ANDROID_API}/lib/libssl.a" "${OUTPUT_DIR}/../lib/libs/${ANDROID_ABI}/"
}

build   android-arm64   21  arm64-v8a
build   android-arm     16  armeabi-v7a
build   android-x86_64  21  x86_64
build   android-x86     16  x86
