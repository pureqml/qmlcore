#!/bin/bash

set -euo pipefail

MAIN=$0

die() { echo "$*" 1>&2 ; exit 1; }

if [ -z "$ANDROID_HOME" ]; then
	die "environment variable ANDROID_HOME=~/location/to/your/android/sdk required"
fi

BUILD_DIR=${PWD}/build.pure.femto.app
APP_NAME=''

while getopts ":a:" OPTNAME; do
	case ${OPTNAME} in
		a)
			APP_NAME="${OPTARG}"
			;;
		:)
			die "Error: -${OPTARG} requires an argument."
			;;
		?)
			die "${MAIN} -a <app> specify app to bundle"
			exit 0
			;;
		*)
			echo "Invalid option ${OPTNAME}"
			exit 1
			;;
	esac
done

export PATH=$PATH:$ANDROID_HOME/tools/
export PATH=$PATH:$ANDROID_HOME/platform-tools/

APP_DIR=${BUILD_DIR}/qmlcore-android
if [ ! -d ${APP_DIR} ]; then
	echo "installing android runtime..."
	mkdir -p ${BUILD_DIR}
	pushd ${BUILD_DIR}
	git clone https://github.com/pureqml/qmlcore-android.git
	popd
else
	pushd ${BUILD_DIR}
	git -C qmlcore-android pull
	popd
fi

echo "compiling app..."
SRC_DIR=${PWD}/build.pure.femto
rm -rf ${SRC_DIR}
./qmlcore/build -j -p pure.femto ${APP_NAME}
if [ ! -d ${SRC_DIR} ]; then
	echo "could not find project in ${SRC_DIR}"
	exit 1
fi

if [ -n "${APP_NAME}" ]; then
	echo "using app name ${APP_NAME}..."
	SRC_DIR="${SRC_DIR}/${APP_NAME}"
else
	echo "using top-level build dir..."
fi

APP_TITLE=$(./qmlcore/build -j -p pure.femto -P title ${APP_NAME} 2>/dev/null) || die "you have to specify application title in .manifest/properties.title"
APP_DOMAIN=$(./qmlcore/build -j -p pure.femto -P domain ${APP_NAME} 2>/dev/null) || die "you have to specify application domain/package in .manifest/properties.domain"
echo "app domain: ${APP_DOMAIN}, title: ${APP_TITLE}"

echo "bundling..."
DST_DIR=${BUILD_DIR}/app

rm -rf ${DST_DIR}
mkdir -p ${DST_DIR}
git -C ${APP_DIR} checkout-index -a --prefix=${DST_DIR}/

ASSETS_DIR="${DST_DIR}/app/src/main/assets"
rm "${ASSETS_DIR}/.keep"

pushd ${ASSETS_DIR}
	echo "using ${SRC_DIR} as source directory"
	cp -a ${SRC_DIR}/* .
	mv qml.*.js main.js 2>/dev/null || die "Could not find qml.*.js in build directory, in case your project has multiple app, specify the name with -a, e.g -a <appname>"
	if [ -e ${SRC_DIR}/icon.png ]; then
		mv ${SRC_DIR}/icon.png ../ic_launcher-web.png
	fi
popd

pushd ${DST_DIR}
	P="s/\\/\\* import \\\${manifest\\.domain}\\.R;.*\$/import ${APP_DOMAIN}.R;/"
	sed -i "${P}" app/src/main/java/com/pureqml/android/MainActivity.java
	P="s/package=\"com.pureqml.android\"/package=\"${APP_DOMAIN}\"/"
	sed -i "${P}" app/src/main/AndroidManifest.xml
	P="s/<string name=\"app_name\">QMLCoreAndroidRuntime<\\/string>/<string name=\"app_name\">${APP_TITLE}<\\/string>/"
	sed -i "${P}" app/src/main/res/values/strings.xml
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

