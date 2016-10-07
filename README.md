# Qml2js: QML to JS translator
Qml2js is simple tool we use for years, simplifying building of html5 UI for both mobile and desktop targets.
It was designed with original QML in mind, but it's not 100% compatible and better in some aspects. 

# Usage
Qml2js provides a set of tools written in python2 (sorry about that, lol)
Usually you don't need to use them directly. ```build``` provides convenient wrapper around them all. 

## Prerequisites
Any modern python 2.x will go well. Jinja2 is better option for templating in case you want more than qml loader in your html file

## Simple how-to
* Create project directory, ```cd <project-dir>```
* Clone qml2js to it: ```git clone git@github.com:pureqml/qml2js.git```
* Run ./qml2js --boilerplate
* Look into app.qml
* Run ./qml2js/build
Please find resulting files in .app.html5/*

## Controls library
Qml2js contains bare minimum of platform controls: images, texts, rectangles and model-view-delegate classes. Various controls that might be useful are in separate repository. 
Just clone it ```git clone git@github.com:pureqml/controls.git``` in your project and that's it!

## QML differences
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
