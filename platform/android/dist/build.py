#!/usr/bin/env python2.7

import argparse
import os


def build(app, title):
    os.system('rm -rf %s' %app)
    res = os.system('cordova create %s com.example.app %s' %(app,title))
    if res != 0:
        print "Failed to create android app"
        return
    os.system('cp -r `ls -A | grep -v "%s"` %s/www' %(app,app))
    os.chdir(app)
    os.system('cordova platform add android')
    os.system('cordova build android')
    os.chdir('..')


parser = argparse.ArgumentParser('qmlcore build tool')
parser.add_argument('--app', '-a', help='application name', default="app")
parser.add_argument('--title', '-t', help='application title', default="App")
args = parser.parse_args()


res = os.system('cordova --version')
if res == 0:
    build(args.app, args.title)
else:
    print 'Install "cordova" first: https://cordova.apache.org/docs/en/latest/guide/cli/'
