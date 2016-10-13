Item {
	signal leftJoystickX;
	signal leftJoystickY;
	signal rightJoystickX;
	signal rightJoystickY;

	property int index;
	property int buttonsCount;
	property int axesCount;
	property bool connected: false;
	property string deviceInfo;

	function poll(gp) {
		var event = { 'type': 'keydown', 'source': 'gamepad', 'index': gp.index }
		if (gp.axes && gp.axes.length >= 4) {
			// Left joystick.
			if (gp.axes[0])
				this.leftJoystickX(gp.axes[0])
			if (gp.axes[1])
				this.leftJoystickY(gp.axes[1])

			// Right joystick.
			if (gp.axes[2])
				this.rightJoystickX(gp.axes[2])
			if (gp.axes[3])
				this.rightJoystickY(gp.axes[3])
		}
		if (gp.buttons.length >= 16) {
			// Functional buttons.
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
	}
}
