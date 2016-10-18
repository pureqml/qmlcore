Item {
	signal axes;
	signal button;

	property int index;
	property int buttonsCount;
	property int axesCount;
	property bool connected: false;
	property string deviceInfo;

	constructor : {
		this._state = {}
		this._mapping = {
			axes: [ "leftStickX", "leftStickY", "rightStickX", "rightStickY"],
			button: [
				"a", "b", "x", "y",
				"leftBumper", "rightBumper", "leftTrigger", "rightTrigger",
				"back", "start", "leftStick", "rightStick",
				"up", "down", "left", "right", "guide"
			]
		}
	}

	function _set(name, idx, n, value) {
		//log(name, idx, value)
		var _state = this._state
		var values
		if (!(name in _state))
			values = _state[name] = Array(n)
		else
			values = _state[name]

		var old = values[idx] || 0
		var delta = value - old
		if (delta != 0) {
			values[idx] = value
			var mapping = this._mapping[name] || []
			var mapName = mapping[idx]
			if (mapName) this.emit(mapName, value, delta); else this.emit(name, idx, value, delta)
		}
	}

	function get(name, idx) {
		var values = this._state[name] || []
		return values[idx] || 0
	}

	function poll(gp) {
		var event = { 'type': 'keydown', 'source': 'gamepad', 'index': gp.index }
		if (gp.axes) {
			var axes = gp.axes
			var n = axes.length
			for(var i = 0; i < n; ++i) {
				this._set('axes', i, n, axes[i])
			}
		}
		if (gp.buttons) {
			var buttons = gp.buttons
			var n = buttons.length
			for(var i = 0; i < n; ++i) {
				this._set('button', i, n, buttons[i].value)
			}
		}
	}

/*
	//add translation here
			// Functional buttons.
		if (gp.buttons.length >= 16) {}
			if (gp.buttons[0].pressed)
				event.which = 114
			else if (gp.buttons[1].pressed)
				event.which = 112
			else if (gp.buttons[2].pressed)
				event.which = 113
			else if (gp.buttons[3].pressed)
				event.which = 115
			// Trigger buttons.
			else if (gp.buttons[4].pressed)
				event.which = 6661
			else if (gp.buttons[5].pressed)
				event.which = 6663
			else if (gp.buttons[6].pressed)
				event.which = 6662
			else if (gp.buttons[7].pressed)
				event.which = 6664
			// Select button.
			else if (gp.buttons[8].pressed)
				event.which = 27
			// Start button.
			else if (gp.buttons[9].pressed)
				event.which = 6665
			// Left joystick.
			else if (gp.buttons[10].pressed)
				event.which = 13
			// Right joystick.
			else if (gp.buttons[11].pressed)
				event.which = 13
			// Navigation keys.
			else if (gp.buttons[12].pressed)
				event.which = 38
			else if (gp.buttons[13].pressed)
				event.which = 40
			else if (gp.buttons[14].pressed)
				event.which = 37
			else if (gp.buttons[15].pressed)
				event.which = 39
		}

		if (gp.buttons.length >= 17)
			if (gp.buttons[16].pressed)
				log("button 16")
		if (event.which)
			this._context._processKey(event)

*/

}
