log = console.log.bind(console)

if (navigator.userAgent.indexOf('Android') >= 0) {
	_globals.core.__deviceBackend = function() { return _globals.android.device }

	log("Android detected")
	exports.core.vendor = "google"
	exports.core.device = 2
	exports.core.os = "android"

	exports.core.keyCodes = {
		4: 'Back',
		13: 'Select',
		32: 'Space',
		33: 'PageUp',
		34: 'PageDown',
		37: 'Left',
		38: 'Up',
		39: 'Right',
		40: 'Down',
		48: '0',
		49: '1',
		50: '2',
		51: '3',
		52: '4',
		53: '5',
		54: '6',
		55: '7',
		56: '8',
		57: '9',
		179: 'Pause',
		112: 'Red',
		113: 'Green',
		114: 'Yellow',
		115: 'Blue'
	}

	if (window.cordova) {
		document.addEventListener("backbutton", function(e) {
			var event = new KeyboardEvent("keydown", { bubbles : true });
			Object.defineProperty(event, 'keyCode', { get : function() { return 4; } })
			document.dispatchEvent(event);
		}, false);
	} else {
		log("'cordova' not defined. 'Back' button will be unhandable. It looks like you forget to include 'cordova.js'")
	}

	document.addEventListener("deviceready", function() {
		_globals._context.system.vendor = device.manufacturer
	}, false);

	log("Android initialized")

	exports.closeApp = function() {
		navigator.app.exitApp();
	}
}
