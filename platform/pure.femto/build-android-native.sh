#!/bin/bash
set -euo pipefail

if [ -z "$ANDROID_HOME" ]; then
	echo "environment variable ANDROID_HOME=~/location/to/your/android/sdk required"
	exit 1
fi

export PATH=$PATH:$ANDROID_HOME/tools/
export PATH=$PATH:$ANDROID_HOME/platform-tools/

BUILD_DIR=${PWD}/build.pure.femto.app
APP_DIR=${BUILD_DIR}/qmlcore-android
if [ ! -d ${APP_DIR} ]; then
	echo "installing android runtime..."
	mkdir -p ${BUILD_DIR}
	pushd ${BUILD_DIR}
	git clone https://github.com/pureqml/qmlcore-android.git
	popd
fi

echo "compiling app..."
SRC_DIR=${PWD}/build.pure.femto
rm -rf ${SRC_DIR}
./qmlcore/build -j -p pure.femto
if [ ! -d ${SRC_DIR} ]; then
	echo "could not find project in ${SRC_DIR}"
	exit 1
fi

echo "bundling..."
DST_DIR=${BUILD_DIR}/app

rm -rf ${DST_DIR}
mkdir -p ${DST_DIR}
git -C ${APP_DIR} checkout-index -a --prefix=${DST_DIR}/

ASSETS_DIR="${DST_DIR}/app/src/main/assets"
rm "${ASSETS_DIR}/.keep"

pushd ${ASSETS_DIR}
	cp -a ${SRC_DIR}/* .
	if [ -e icon.png ];then
		mv icon.png ../ic_launcher-web.png
		mv qml.*.js main.js
	fi
popd

echo "building"
pushd ${DST_DIR}
TERM=xterm-color ./gradlew build #workaround grandle bug
popd

echo
echo
echo "build finished, outputting apk locations:"
echo
find ${BUILD_DIR} -iname '*.apk'

