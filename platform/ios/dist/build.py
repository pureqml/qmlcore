#!/usr/bin/env python2.7

import argparse
import os


def build(app, title):
    os.system('rm -rf %s' %app)
    res = os.system('cordova create %s com.%s.app %s' %(app, app, title))
    if res != 0:
        print "Failed to create ios app"
        return
    os.system('cp -r `ls -A | grep -v "%s"` %s/www' %(app,app))
    os.system('cp icon.png %s' %(app))
    os.system('cp config.xml %s' %(app))
    os.chdir(app)

    {% block commands %}{% endblock %}

    os.system('cordova platform add ios')

    {% block plugins %}{% endblock %}

    os.system('cordova build ios')
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
