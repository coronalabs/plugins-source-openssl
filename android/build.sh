#!/bin/sh

# This option is used to exit the script as
# soon as a command returns a non-zero value.
set -ex

path=$(dirname "$0")
path=$(realpath "$path")
OUTPUT_DIR=${1:-libs}
mkdir -p "$OUTPUT_DIR"
OUTPUT_DIR=$(realpath "$OUTPUT_DIR")

"$path"/gradlew clean :plugin_openssl:assembleRelease

######################
# Post-compile Steps #
######################

# Overwrite existing files without prompting is discourage.
unzip "plugin_openssl/build/outputs/aar/plugin_openssl-release.aar" "jni/*" -d "$OUTPUT_DIR"
cp metadata.lua "$OUTPUT_DIR"

echo Done.
