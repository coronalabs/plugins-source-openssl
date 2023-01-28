#!/bin/bash

set -ex

path=$(realpath "$(dirname $0)")

OUTPUT_DIR_TVOS=${1:-./appletvos}
mkdir -p "$OUTPUT_DIR_TVOS"
OUTPUT_DIR_TVOS=$(realpath "$OUTPUT_DIR_TVOS")

OUTPUT_DIR_TVOS_SIM=${2:-./appletvsimulator}
mkdir -p "$OUTPUT_DIR_TVOS_SIM"
OUTPUT_DIR_TVOS_SIM=$(realpath "$OUTPUT_DIR_TVOS_SIM")

# tvOS force Corona_X
PLUGIN_NAME=Corona_plugin_opensslv3
# PLUGIN_NAME=${3:-Corona_plugin_opensslv3}

OUTPUT_SUFFIX=framework
CONFIG=Release

# tvOS
xcodebuild -project "$path/Plugin.xcodeproj" -configuration $CONFIG clean
xcodebuild -project "$path/Plugin.xcodeproj" -target "$PLUGIN_NAME" -configuration $CONFIG -sdk appletvos
xcodebuild -project "$path/Plugin.xcodeproj" -target "$PLUGIN_NAME" -configuration $CONFIG -sdk appletvsimulator

cp -R "$path/build/$CONFIG-appletvos/$PLUGIN_NAME.$OUTPUT_SUFFIX" "$OUTPUT_DIR_TVOS"/
cp -R "$path/build/$CONFIG-appletvsimulator/$PLUGIN_NAME.$OUTPUT_SUFFIX" "$OUTPUT_DIR_TVOS_SIM"/
