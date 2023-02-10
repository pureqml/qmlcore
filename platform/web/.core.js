_globals.core.__deviceBackend = function() { return _globals.web.device }

var keyCodes = {
	13: 'Select',
	16: 'Shift',
	17: 'Ctrl',
	18: 'LeftAlt',
	27: 'Back',
	37: 'Left',
	32: 'Space',
	33: 'PageUp',
	34: 'PageDown',
	36: 'Menu',
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
	// NumPad
	96: '0',
	97: '1',
	98: '2',
	99: '3',
	100: '4',
	101: '5',
	102: '6',
	103: '7',
	104: '8',
	105: '9',
}

if ($manifest$emulateRemoteKeys) {
	var emulatedKeys = {
		112: 'Red',
		113: 'Green',
		114: 'Yellow',
		115: 'Blue',
		219: 'Red',     // [
		221: 'Green',   // ]
		186: 'Yellow',  // ;
		222: 'Blue',    // '
		230: 'RightAlt',
		187: 'VolumeUp',
		189: 'VolumeDown',
		191: 'Mute',
		// NumPad
		107: 'VolumeUp',
		109: 'VolumeDown',
		111: 'Mute',
	}
	for(var code in emulatedKeys) {
		keyCodes[code] = emulatedKeys[code]
	}
}

exports.core.keyCodes = keyCodes

exports.closeApp = function() {
	window.close()
}
