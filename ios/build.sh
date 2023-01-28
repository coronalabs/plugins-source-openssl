#!/bin/bash

set -ex

path=$(dirname "$0")

OUTPUT_DIR_IOS=$1
OUTPUT_DIR_IOS_SIM=$2
TARGET_NAME=$3
echo ${TARGET_NAME:?"is empty"}
OUTPUT_SUFFIX=a
CONFIG=Release

#
# Checks exit value for error
#
checkError() {
	if [ $? -ne 0 ]
	then
		echo "Exiting due to errors (above)"
		exit -1
	fi
}

#
# Canonicalize relative paths to absolute paths
#
pushd "$path" > /dev/null
dir=$(pwd)
path=$dir
popd > /dev/null

echo "OUTPUT_DIR_IOS: $(realpath ${OUTPUT_DIR_IOS:=./iphoneos})"
echo "OUTPUT_DIR_IOS_SIM: $(realpath ${OUTPUT_DIR_IOS_SIM:=./iphonesimulator})"

# Clean
xcodebuild -project "$path/Plugin.xcodeproj" -configuration $CONFIG clean
checkError

# iOS
xcodebuild -project "$path/Plugin.xcodeproj" -configuration $CONFIG -sdk iphoneos
checkError

# iOS-sim
xcodebuild -project "$path/Plugin.xcodeproj" -configuration $CONFIG -sdk iphonesimulator
checkError

# copy binary to dst
cp -v "$path"/build/$CONFIG-iphoneos/lib$TARGET_NAME.$OUTPUT_SUFFIX "$OUTPUT_DIR_IOS"/lib$TARGET_NAME.$OUTPUT_SUFFIX
cp -v "$path"/build/$CONFIG-iphonesimulator/lib$TARGET_NAME.$OUTPUT_SUFFIX "$OUTPUT_DIR_IOS_SIM"/lib$TARGET_NAME.$OUTPUT_SUFFIX
