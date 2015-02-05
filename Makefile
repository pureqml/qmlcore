all:
		./qml-compiler -o app core tv
		java -jar compiler/gcc/compiler.jar --compilation_level ADVANCED_OPTIMIZATIONS app/qml.js