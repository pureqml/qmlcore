# PureQML::QMLCore: QML to JS translator
QmlCore is simple set of tools we (small team of QML advocates) used for years, simplifying building of html5 UI for both mobile and desktop targets.
It was designed with original QML in mind, but it's not 100% compatible and better in some aspects. The main concepts are the same though, so if you're familiar with original QML, you could start right away. 

## Usage
QmlCore provides a set of tools written in python2 (sorry about that, lol)
Usually you don't need to use them directly. ```build``` provides convenient wrapper around them all. 

### Prerequisites
Any modern python 2.x will go well. Jinja2 is better option for templating in case you want more than qml loader in your html file, but it's not required for small apps. 

## Simple how-to
* Create project directory, ```cd <project-dir>```
* Clone QmlCore to it: ```git clone git@github.com:pureqml/qmlcore.git```
* Run ./qmlcore --boilerplate
* Look into app.qml
* Run ./qmlcore/build
Please find resulting files in .app.web/*

## How it works
Qml compiler scans source directories for qml file and parses each one. Filename starting with uppercase letter considered component, lowercase instantiated. Project-wide options stored in ```.manifest``` file. Result of the compilation is single javascript file with minimum dependencies (modernizr only), ready to use in mobile and desktop environment, accompanied by sample .html launcher and flash video player. 

## Manifest options
Manifest is a collection of project-wide hacks we used to botch various projects. Some of them may or may not be useful.
* ```apps``` - dictionary of application and their templates, { app1: template1, app2: template2, app3: template1 }. Templates are taken from dist/ or platform/*/dist directory
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
* ```--boilerplate``` initialises bare minimum for quicker kick-off in current directory.

# Localisation
QmlCore uses Qt-approach to localisation. You write code in your default language, then generate/update (build -u) .ts translation files,
translate them with qt linguist, and compile project. QmlCore recognizes tr, qsTr, qsTranslate function, as well as QT_TR_NOOP/QT_TRANSLATE_NOOP macros.

# Controls library
QmlCore contains bare minimum of platform controls: images, texts, rectangles and model-view-delegate classes. Various controls that might be useful are in separate repository. 
Just clone it ```git clone git@github.com:pureqml/controls.git``` in your project and that's it!

# QML differences
### Grammar
We require semicolon after each statement. This may be changed in future. 

### Focus
The biggest discrepancy with original QML is focus implementation. We're aiming to have "always-consistent" focus everywhere. 
You have to mark every focus-able component with ```focus: true;``` property, and the rest should work without tweaking. 
We provide several convenient properties to handle focus with ease:
- activeFocus — this item has current focus and got any user input first
- focused — this item has current focus in its parent, but not necessarily focused globally

## Random customization notes
### Adding modernizr features
Please use the following command to get the custom modernizr build page:
```head -n2 dist/modernizr-custom.js | tail -n1```
or just second line of modernizr-custom.js file
