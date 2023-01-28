#!/bin/bash

# build OpenSSL 3.0.8 with NDK r18b, April 2023

set -ex

OUTPUT_LIBDIR="$(realpath $(dirname $0))/lib"

# check OUTPUT_DIR
OUTPUT_DIR=${1:-./build_macos_openssl}
mkdir -p "${OUTPUT_DIR}"
# OpenSSL Configure needs absolute path
OUTPUT_DIR=$(realpath $OUTPUT_DIR)

# tested with OpenSSL 3.0.8
OPENSSL_VERSION=${OPENSSL_VERSION:-"openssl-3.0.8"}
if [ ! -f "${OUTPUT_DIR}/${OPENSSL_VERSION}.tar.gz" ]; then
    curl -L "https://github.com/openssl/openssl/releases/download/${OPENSSL_VERSION}/${OPENSSL_VERSION}.tar.gz" -o "${OUTPUT_DIR}/${OPENSSL_VERSION}.tar.gz";
fi
tar -xf "${OUTPUT_DIR}/${OPENSSL_VERSION}.tar.gz" --directory "${OUTPUT_DIR}"
export OPENSSL_LOCAL_CONFIG_DIR=$(realpath "$(dirname "$0")/config")
cd "${OUTPUT_DIR}/${OPENSSL_VERSION}"

# make JOBS, tested on macOS
JOBS=$(sysctl -n hw.ncpu)
JOBS=${JOBS:=1}

# # tested with NDK r18b
# NDK_HOSTNAME=${NDK_HOSTNAME:=darwin-x86_64}
# ANDROID_NDK=${ANDROID_NDK:?"Config NDK first"}
# ANDROID_NDK_ROOT=${ANDROID_NDK}
# PATH=${ANDROID_NDK}/toolchains/llvm/prebuilt/${NDK_HOSTNAME}/bin:${PATH}

build() {
    TARGET=${1:?"Specify one of macos-x86_64, macos-arm64 as target"}

    make -j${JOBS} clean || true

    # Build openssl libraries
    ./Configure "${TARGET}" \
        threads no-shared \
        --prefix="${OUTPUT_DIR}/builds/${TARGET}" --openssldir="${OUTPUT_DIR}/builds/${TARGET}"

    make -j${JOBS} clean
    make -j${JOBS} build_sw
    make -j${JOBS} install_sw
}

build   macos-x86_64
build   macos-arm64

lipo -create "${OUTPUT_DIR}/builds/macos-arm64/lib/libcrypto.a" "${OUTPUT_DIR}/builds/macos-x86_64/lib/libcrypto.a" -output "${OUTPUT_DIR}/builds/libcrypto-macos.a"
lipo -create "${OUTPUT_DIR}/builds/macos-arm64/lib/libssl.a" "${OUTPUT_DIR}/builds/macos-x86_64/lib/libssl.a" -output "${OUTPUT_DIR}/builds/libssl-macos.a"

# copy to ${OUTPUT_LIBDIR}
mkdir -p "${OUTPUT_LIBDIR}/include"
cp -r "${OUTPUT_DIR}/builds/macos-arm64/include/openssl" "${OUTPUT_LIBDIR}/include/"
cp -r "${OUTPUT_DIR}/builds/libcrypto-macos.a" "${OUTPUT_LIBDIR}"
cp -r "${OUTPUT_DIR}/builds/libssl-macos.a" "${OUTPUT_LIBDIR}"
