Item {
	id: gamepadManagerProto;
	signal connected;
	signal disconnected;

	property int count: 0;
	property bool gamepadChildrensCount: 0;
	property variant _gamepads;

	Timer {
		id: startupTimer;
		interval: 1000;
		repeat: false;

		onTriggered: { gamepadManagerProto.pollGamepads() }
	}

	Timer {
		interval: 100;
		repeat: true;
		running: gamepadManagerProto.gamepadChildrensCount;
		triggeredOnStart: true;

		onTriggered: { gamepadManagerProto.gpButtonCheckLoop() }
	}

	pollGamepads: {
		clearInterval(this._gpPollInterval)
		var gamepads = navigator.getGamepads ? navigator.getGamepads() : (navigator.webkitGetGamepads ? navigator.webkitGetGamepads : []);
		for (var i = 0; i < gamepads.length; ++i) {
			var gamepad = gamepads[i]
			if (gamepad)
				this.gamepadConnectedHandler({ 'gamepad': gamepad })
		}
	}

	gpButtonCheckLoop: {
		clearInterval(this._gpButtonsPollInterval);
		var gamepads = navigator.getGamepads ? navigator.getGamepads() : (navigator.webkitGetGamepads ? navigator.webkitGetGamepads : []);
		for (var i in gamepads) {
			if (!gamepads[i] || !gamepads[i].buttons)
				continue

			var gp = gamepads[i]
			var gpItem

			for (var i = 0; i < this.children.length; ++i) {
				var c = this.children[i]
				if (c instanceof _globals.core.Gamepad && c.connected && c.index == gp.index) {
					gpItem = c
					break
				}
			}

			if (!gp || !gpItem)
				continue

			var event = { 'type': 'keydown', 'source': 'gamepad', 'index': gp.index }
			if (gp.axes && gp.axes.length >= 4) {
				// Left joystick.
				if (gp.axes[0])
					gpItem.leftJoystickX(gp.axes[0])
				if (gp.axes[1])
					gpItem.leftJoystickY(gp.axes[1])

				// Right joystick.
				if (gp.axes[2])
					gpItem.rightJoystickX(gp.axes[2])
				if (gp.axes[3])
					gpItem.rightJoystickY(gp.axes[3])
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

	gamepadConnectedHandler(event): {
		this.connected(event.gamepad)

		if (!this._gamepads)
			this._gamepads = {}
		this._gamepads[event.gamepad.index] = event.gamepad
		++this.count

		if (!_globals.core.Gamepad) {
			log("No 'Gamepad' instance found, add at least one 'Gamepad' item inside 'GamepadManager' scope.")
			return
		}

		var children = this.children
		var g = event.gamepad
		for (var i = 0; i < children.length; ++i) {
			var c = children[i]
			if (c instanceof _globals.core.Gamepad && !c.connected) {
				c.index = g.index
				c.connected = true
				c.deviceInfo = g.id
				c.buttonsCount = g.buttons.length
				c.axesCount = g.axes.length
				++this.gamepadChildrensCount
				break
			}
		}
	}

	gamepadDisconnectedHandler(event): {
		this.disconnected(event.gamepad)
		delete this._gamepads[event.gamepad.index]
		--this.count

		if (!_globals.core.Gamepad) {
			log("No 'Gamepad' instance found, add at least one 'Gamepad' item inside 'GamepadManager' scope.")
			return
		}

		var g = event.gamepad
		var children = this.children

		for (var i = 0; i < children.length; ++i) {
			var c = children[i]
			if (c instanceof _globals.core.Gamepad && c.index == g.index) {
				c.index = -1
				c.connected = false
				c.deviceInfo = ""
				c.buttonsCount = 0
				c.axesCount = 0
				--this.gamepadChildrensCount
				break
			}
		}
	}

	onCompleted: {
		this._gpButtonsPollInterval = {}
		this._gpPollInterval = {}

		startupTimer.restart()

		window.addEventListener('gamepadconnected', this.gamepadConnectedHandler.bind(this))
		window.addEventListener('gamepaddisconnected', this.gamepadDisconnectedHandler.bind(this))
	}
}
