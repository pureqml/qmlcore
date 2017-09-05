if (typeof navigator !== 'undefined') {
	exports.core.os = navigator.platform
	exports.core.userAgent = navigator.userAgent
	exports.core.language = navigator.language
} else if ((typeof process !== 'undefined') && (process.release.name === 'node')) {
	exports.core.os = process.platform
	exports.core.userAgent = process.release.name
} else {
	exports.core.os = 'unknown'
	exports.core.userAgent = 'Unknown'
}

exports.core.keyCodes = {
	13: 'Select',
	27: 'Back',
	37: 'Left',
	32: 'Space',
	33: 'PageUp',
	34: 'PageDown',
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
	65: 'A',
	66: 'B',
	67: 'C',
	68: 'D',
	69: 'E',
	70: 'F',
	71: 'G',
	72: 'H',
	73: 'I',
	74: 'J',
	75: 'K',
	76: 'L',
	77: 'M',
	78: 'N',
	79: 'O',
	80: 'P',
	81: 'Q',
	82: 'R',
	83: 'S',
	84: 'T',
	85: 'U',
	86: 'V',
	87: 'W',
	88: 'X',
	89: 'Y',
	90: 'Z',
	112: 'Red',
	113: 'Green',
	114: 'Yellow',
	115: 'Blue'
}

var _checkDevice = function(target, info) {
	if (exports.core.userAgent.indexOf(target) < 0)
		return

	exports.core.vendor = info.vendor
	exports.core.device = info.device
	exports.core.os = info.os
}

if (!exports.core.vendor) {
	_checkDevice('Blackberry', { 'vendor': 'blackberry', 'device': 2, 'os': 'blackberry' })
	_checkDevice('Android', { 'vendor': 'google', 'device': 2, 'os': 'android' })
	_checkDevice('iPhone', { 'vendor': 'apple', 'device': 2, 'os': 'iOS' })
	_checkDevice('iPad', { 'vendor': 'apple', 'device': 2, 'os': 'iOS' })
	_checkDevice('iPod', { 'vendor': 'apple', 'device': 2, 'os': 'iOS' })
}

if (exports.core.userAgent.indexOf('Chromium') >= 0)
	exports.core.browser = "Chromium"
else if (exports.core.userAgent.indexOf('Chrome') >= 0)
	exports.core.browser = "Chrome"
else if (exports.core.userAgent.indexOf('Opera') >= 0)
	exports.core.browser = "Opera"
else if (exports.core.userAgent.indexOf('Firefox') >= 0)
	exports.core.browser = "Firefox"
else if (exports.core.userAgent.indexOf('Safari') >= 0)
	exports.core.browser = "Safari"
else if (exports.core.userAgent.indexOf('MSIE') >= 0)
	exports.core.browser = "IE"
else if (exports.core.userAgent.indexOf('YaBrowser') >= 0)
	exports.core.browser = "Yandex"
else
	exports.core.browser = ''


_globals._backend = function() { return _globals.html5.html }
