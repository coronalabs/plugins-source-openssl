#!/bin/bash

# build OpenSSL 3.0.8 with Xcode 14, April 2023

set -ex

OUTPUT_LIBDIR="$(realpath $(dirname $0))/lib"

# check OUTPUT_DIR
OUTPUT_DIR=${1:-./build_tvos_openssl}
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

build() {
    TARGET=${1:?"Specify one of tvos-arm64, tvos-sim-x86_64, tvos-sim-arm64 as target"}

    make -j${JOBS} clean || true

    # Build openssl libraries
    ./Configure "${TARGET}" \
        no-threads no-shared no-tests \
        --prefix="${OUTPUT_DIR}/builds/${TARGET}" --openssldir="${OUTPUT_DIR}/builds/${TARGET}"

    make -j${JOBS} clean
    make -j${JOBS} build_sw
    make -j${JOBS} install_sw
}

build   tvos-arm64
build   tvos-sim-x86_64
# when build OpenSSL with "-mtvos-version-min=9.0" xcodebuild misjudge "appletvsimulator arm64" as "appletvos"
build   tvos-sim-arm64

lipo -create "${OUTPUT_DIR}/builds/tvos-arm64/lib/libcrypto.a" -output "${OUTPUT_DIR}/builds/libcrypto-tvos.a"
lipo -create "${OUTPUT_DIR}/builds/tvos-arm64/lib/libssl.a" -output "${OUTPUT_DIR}/builds/libssl-tvos.a"

lipo -create "${OUTPUT_DIR}/builds/tvos-sim-x86_64/lib/libcrypto.a" "${OUTPUT_DIR}/builds/tvos-sim-arm64/lib/libcrypto.a" -output "${OUTPUT_DIR}/builds/libcrypto-tvos-sim.a"
lipo -create "${OUTPUT_DIR}/builds/tvos-sim-x86_64/lib/libssl.a" "${OUTPUT_DIR}/builds/tvos-sim-arm64/lib/libssl.a" -output "${OUTPUT_DIR}/builds/libssl-tvos-sim.a"

xcodebuild -create-xcframework -library "${OUTPUT_DIR}/builds/libcrypto-tvos.a" -library "${OUTPUT_DIR}/builds/libcrypto-tvos-sim.a" -output "${OUTPUT_DIR}/builds/libcrypto.xcframework"
xcodebuild -create-xcframework -library "${OUTPUT_DIR}/builds/libssl-tvos.a" -library "${OUTPUT_DIR}/builds/libssl-tvos-sim.a" -output "${OUTPUT_DIR}/builds/libssl.xcframework"

# copy to ${OUTPUT_LIBDIR}
mkdir -p "${OUTPUT_LIBDIR}/include"
cp -r "${OUTPUT_DIR}/builds/tvos-sim-arm64/include/openssl" "${OUTPUT_LIBDIR}/include/"
cp -r "${OUTPUT_DIR}/builds/libcrypto.xcframework" "${OUTPUT_LIBDIR}"
cp -r "${OUTPUT_DIR}/builds/libssl.xcframework" "${OUTPUT_LIBDIR}"
