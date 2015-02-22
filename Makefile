.PHONY: all dev test-dev dist

all:
		./qml-compiler -w -o app core controls domru platform/html5 tv

dist:
		./qml-compiler -o app core controls domru platform/html5 tv
		java -jar compiler/gcc/compiler.jar --externs compiler/gcc/jquery-1.9.js app/qml.js > app/qml.min.js


test-dev:
		./qml-compiler -w -o app core controls test

test-advanced:
		./qml-compiler -o app core controls test
		java -jar compiler/gcc/compiler.jar --compilation_level ADVANCED_OPTIMIZATIONS --externs compiler/gcc/jquery-1.9.js app/qml.js > app/qml.min.js

smarttv:
		./qml-compiler -o app core controls domru  platform/smarttv tv
		java -jar compiler/gcc/compiler.jar --externs compiler/gcc/jquery-1.9.js app/qml.js > app/qml.min.js
