// RUN: %build
// RUN: grep "this.a = (2 + (((2 \* 2) \% 3) / 4))" %out/qml.expr.js
// RUN: grep "this.b = ((~ 1) - (~ 2))" %out/qml.expr.js
// RUN: grep "this.c = ((2 \*\* 2) + 2)" %out/qml.expr.js
// RUN: grep "this.d = ((+ 3) + (- 2))" %out/qml.expr.js
// RUN: grep "this.e = (~ (~ 0))" %out/qml.expr.js
// RUN: grep "this.f = ((1 + 1) << (2 + 1))" %out/qml.expr.js
// RUN: grep "this.g = (1 + (2 \* (1 + 1)))" %out/qml.expr.js
// RUN: grep "this.h = \[(1 \*\* 2),\$this.a,\$this.b\]" %out/qml.expr.js
// RUN: grep "this.i = ((\$this.h\[0\]) + ((\$this.h\[1\]) \* (\$this.h\[2\])))" %out/qml.expr.js
// RUN: grep "this.j = (123.456 . toFixed)(2)" %out/qml.expr.js
// RUN: grep "this.k = ((typeof \$this.i) === 'number')" %out/qml.expr.js
// RUN: grep "this.l = \$this.func((\$this.k !== undefined));" %out/qml.expr.js
// RUN: grep "this.m = Date.now();" %out/qml.expr.js
// RUN: grep "this.n = (new Date());" %out/qml.expr.js

Object {
	property int a: 2 + 2 * 2 % 3 / 4;
	property int b: ~1 - ~2;
	property int c: 2 ** 2 + 2;
	property int d: + 3 + - 2;
	property int e: ~~0;
	property int f: 1 + 1 << 2 + 1;
	property int g: 1 + 2 * (1 + 1);
	property array h: [1 ** 2, a, b];
	property int i: h[0] + h[1] * h[2];
	property string j: (123.456).toFixed(2);
	property bool k: typeof i === 'number';
	property bool l: this.func(this.k !== undefined);
	property int m: Date.now();
	property Date n: new Date();
}
