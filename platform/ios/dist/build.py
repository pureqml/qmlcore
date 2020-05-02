#!/usr/bin/env python

from __future__ import print_function

import argparse
import os


def build(app, title):
	os.system('rm -rf %s' %app)
	res = os.system('cordova create %s com.%s.app %s' %(app, app, title))
	if res != 0:
		print("Failed to create ios app")
		return
	os.system('rsync -a ./ %s/www --exclude=%s ' %(app,app))
	# os.system('cp icon.png %s' %(app))
	os.system('cp config.xml %s' %(app))
	os.chdir(app)

	os.system('cordova platform add ios@5.1.0')
	{% block commands %}{% endblock %}

	os.system('cordova plugin add cordova-plugin-device')
	os.system('cordova plugin add cordova-plugin-screen-orientation')
	os.system('cordova plugin add cordova-plugin-wkwebview-engine')
	{% block plugins %}{% endblock %}

	os.system('cordova build ios')

	os.system('cp -r ../icons/* ./platforms/ios/%s/Images.xcassets/AppIcon.appiconset' %(title))

	os.system('cordova run --ios')
	os.chdir('..')


parser = argparse.ArgumentParser('qmlcore build tool')
parser.add_argument('--app', '-a', help='application name', default="app")
parser.add_argument('--title', '-t', help='application title', default="App")
args = parser.parse_args()


res = os.system('cordova --version')
if res == 0:
    build(args.app, args.title)
else:
    print('Install "cordova" first: https://cordova.apache.org/docs/en/latest/guide/cli/')
