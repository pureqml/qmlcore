#!/usr/bin/env python

from __future__ import print_function

import argparse
import os


def build(app, title, release):
	os.system('rm -rf %s' %app)
	res = os.system('cordova create %s com.%s.app %s' %(app, app, title))
	if res != 0:
		print("Failed to create android app")
		return
	os.system('rsync -a ./ %s/www --exclude=%s ' %(app,app))
	os.system('cp icon.png %s' %(app))
	os.system('cp config.xml %s' %(app))
	os.chdir(app)

	os.system('cordova platform add android')
	os.system('cordova plugin add cordova-plugin-streaming-media')
	os.system('cordova plugin add cordova-plugin-device')
	os.system('cordova plugin add cordova-plugin-screen-orientation')

	if release:
		build = 'cordova build android --release -- '
		# TODO: pass release parameters
		# os.system(build + '--keystore={{androidBuild.keystore}} --storePassword={{androidBuild.storePassword}} --alias={{androidBuild.alias}} --password={{androidBuild.password}}')
	else:
		os.system('cordova build android')

	os.chdir('..')


parser = argparse.ArgumentParser('pureqml cordova android build tool')
parser.add_argument('--app', '-a', help='application name', default="app")
parser.add_argument('--title', '-t', help='application title', default="App")
parser.add_argument('--release', '-r', help='build release apk', default=False)
args = parser.parse_args()


res = os.system('cordova --version')
if res == 0:
	build(args.app, args.title, args.release)
else:
	print('Install "cordova" first: https://cordova.apache.org/docs/en/latest/guide/cli/')
