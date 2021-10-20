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
	git clone --depth=1 https://github.com/pureqml/qmlcore-android.git
	popd
else
	pushd ${BUILD_DIR}
	git -C qmlcore-android pull --depth=1
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

APP_TITLE=$(./qmlcore/build -j -p pure.femto -P title ${APP_NAME} 2>/dev/null) || die "you have to specify application title in .manifest/properties.title"
APP_DOMAIN=$(./qmlcore/build -j -p pure.femto -P domain ${APP_NAME} 2>/dev/null) || die "you have to specify application domain/package in .manifest/properties.domain"
APP_ICON_COLOR=$(./qmlcore/build -j -p pure.femto -P iconColor ${APP_NAME} 2>/dev/null) || APP_ICON_COLOR=""
APP_SDK_VERSION=$(./qmlcore/build -j -p pure.femto -P androidtargetSdkVersion ${APP_NAME} 2>/dev/null) || APP_SDK_VERSION="29"

if [ -n "${APP_NAME}" ]; then
	echo "using app name ${APP_NAME}..."
	APP_DOMAIN="${APP_DOMAIN}.${APP_NAME}"
	SRC_DIR="${SRC_DIR}/${APP_NAME}"
else
	echo "using top-level build dir..."
fi
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
	if [ -e ${SRC_DIR}/icons ]; then
		cp -r ${SRC_DIR}/icons/* ../res/.
	fi
popd

pushd ${DST_DIR}
	P="s/package=\"com.pureqml.android\"/package=\"${APP_DOMAIN}\"/"
	sed -i "${P}" app/src/main/AndroidManifest.xml
	P="s/<string name=\"app_name\">QMLCoreAndroidRuntime<\\/string>/<string name=\"app_name\">${APP_TITLE}<\\/string>/"
	sed -i "${P}" app/src/main/res/values/strings.xml
	P="s/-keep public com\\.pureqml\\.android\\./-keep public ${APP_DOMAIN}./g"
	sed -i "${P}" app/proguard-rules.pro
	P="s/applicationId \"com\\.pureqml\\.qmlcore\\.runtime\\.android\"/applicationId \"${APP_DOMAIN}\"/"
	sed -i "${P}" app/build.gradle
	P="s/targetSdkVersion 29/targetSdkVersion ${APP_SDK_VERSION}/"
	sed -i "${P}" app/build.gradle
	P="s/compileSdkVersion 29/compileSdkVersion ${APP_SDK_VERSION}/"
	sed -i "${P}" app/build.gradle


	if [ ! -z "$APP_ICON_COLOR" ]; then
		P="s/#FFFFFF/${APP_ICON_COLOR}/"
		sed -i "${P}" app/src/main/res/values/ic_launcher_background.xml
	fi

	JAVA_SRC=app/src/main/java/$(echo "${APP_DOMAIN}" | tr '.' '/')
	mkdir -p ${JAVA_SRC}
	mv app/src/main/java/com/pureqml/android/* ${JAVA_SRC}/
	rm -rf app/src/main/java/com/pureqml/android
	rmdir -p app/src/main/java/com/pureqml || true
	for J in $(find -name '*.java'); do
		sed -i "s/package com\\.pureqml\\.android/package ${APP_DOMAIN}/" $J
		sed -i "s/import com\\.pureqml\\.android/import ${APP_DOMAIN}/g" $J
		sed -i "s/import static com\\.pureqml\\.android/import static ${APP_DOMAIN}/g" $J
	done
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

