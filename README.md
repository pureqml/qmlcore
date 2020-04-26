# PureQML::QMLCore: QML to Javascript translator
QmlCore is a simple set of tools we (a small team of QML advocates) use since years to simplify the development of HTML5 UIs for both mobile and desktop devices.
It was designed with the original QML in mind, while it's not 100% compatible and improved in some aspects.
The main concepts are the same though, so if you're familiar with original QML, you could start right away.

## Usage
QmlCore provides a toolchain written in Python using python-future, allowing it to be run on top of both python versions.
Normally you don't need to use them directly. ```build``` provides a convenient wrapper around them all.

### Prerequisites
Any modern Python (2 or 3) will go well. Jinja2 is a different option for templating in case you want more than QML loader in your HTML file, while it's not required for small apps.

To install the requirements run:
```python
$ pip install -r requirements.txt
```

## Simple how-to
* Create project directory, ```cd <project-dir>```
* Clone QmlCore to it: ```git clone git@github.com:pureqml/qmlcore.git```
* Run ./qmlcore/build --boilerplate
* Look into ./src/app.qml
* Run ./qmlcore/build
Please find the resulting files in build.web/*

## How it works
The QML compiler scans source directories for QML files and parses each one. Filename starting with uppercase letter considered component, lowercase instantiated. Project-wide options are stored in the ```.manifest``` file. The result of the compilation is a single Javascript file with minimum dependencies (modernizr only), ready to use in mobile and desktop environment and accompanied by sample .html launcher.

## Manifest options
Manifest is a collection of project-wide hacks we used to botch various projects. Some of them may or may not be useful.
* ```templater``` - template engine to use, only 'simple' and 'jinja2' are supported at the moment
* ```web-prefix``` - see -p option below, specify css rules prefix
* ```minify``` - false/true or compiler name as string, only 'gcc' and 'uglify-js' are supported. google closure compiler requires java to run.
* ```platforms``` use additional platform/*/ files, default and only platform is 'web' for now
* ```path``` - additional directories to search sources for

## build tool command line options
* ```-m, --minify``` minify with default option ('uglify-js')
* ```-k, --keep``` keep original source after minification, useful for debugging minification warnings
* ```-d, --devel``` development mode, keep running and wait for changes, requires inotify module
* ```-p, --web-prefix``` web prefix, removed default CSS rules, adds 'qml-' prefix for them, allowing you to interchange HTML/QML.
* ```-u, --update-translation``` update translation files, specified in manifest.languages
* ```-j, --jobs``` run N jobs in parallel
* ```--boilerplate``` initialises bare minimum for quicker kick-off in current directory.

# Supported Platforms
We support many different platforms and video integration variants.

Most notable platforms are:
- HTML5 Web Browser (Obviously) with different addons:
	- Shaka
	- Dash.js
	- Video.js
Web Extension
- ElectronJS
- Android (Native engine and Cordova)
- IOS (Cordova)
- SmartTV Platorms:
	- Any Android TV via native Android support.
	- LG (Netcast and WebOS)
	- Samsung SmartTv (Orsay and Tizen)
	- OperaTV
- Many STB platforms (privately)
- Native C++ engine with minimal requirements (EGL or LinuxFB) (privately)

For the full list of supported platform see [here](https://github.com/pureqml/qmlcore/tree/master/platform) and [here](https://github.com/pureqml/qmlcore-tv/tree/master/platform). Or alternatively just ask us.

## Native Android support
Main repo for Pureqml native Android implementation is https://github.com/pureqml/qmlcore-android.

In order to build native android app you need to:
- Install Android SDK and set `ANDROID_HOME` environment variable
- Run `./qmlcore/platform/pure.femto/build-android-native.sh` script.

# Localisation
QmlCore uses Qt-approach to localisation. You write the code in your default language, then generate/update (build -u) .ts translation files, translate them with qt linguist and compile your project. QmlCore recognizes tr, qsTr, qsTranslate function, as well as QT_TR_NOOP/QT_TRANSLATE_NOOP macros.

# Controls library
QmlCore contains a bare minimum of platform controls: Images, texts, rectangles and model-view-delegate classes. Various controls that might be useful are in a separate repository.
Just clone it via ```git clone git@github.com:pureqml/controls.git``` in your project and that's it!

# QML differences
### Grammar
We require a semicolon after each statement. This may be changed in future.

### Focus
The biggest discrepancy with original QML is how focus is implemented. We're aiming to have "always-consistent" focus everywhere.
You have to mark every focus-able component with ```focus: true;``` property, and the rest should work without tweaking.
We provide several convenient properties to handle focus with ease:
- activeFocus — this item has current focus and got any user input first
- focused — this item has current focus in its parent, but not necessarily focused globally

## Random customization notes
### Adding modernizr features
Please use the following command to get the custom modernizr build page:
```head -n2 dist/modernizr-custom.js | tail -n1```
or just the second line of modernizr-custom.js file

## Thanks

### Modernizr project
Modernizr tells you what HTML, CSS and JavaScript features the user’s browser has to offer.
https://modernizr.com/

### SDL Game Controller Database
A community sourced database of game controller mappings
https://github.com/gabomdq/SDL_GameControllerDB

### Apache Cordova project
Apache Cordova is an open-source mobile development framework. It allows you to use standard web technologies - HTML5, CSS3, and JavaScript for cross-platform development.
https://cordova.apache.org
