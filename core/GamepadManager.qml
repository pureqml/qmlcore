Item {
	signal connected;
	signal disconnected;

	property int count: 0;
	property bool gamepadChildrensCount: 0;
	property variant _gamepads;
	property int gamepadPollingInterval: 1000;
	property int eventPollingInterval: 8; //120fps

	Timer {
		id: startupTimer;
		interval: parent.gamepadPollingInterval;
		repeat: false;
		triggeredOnStart: true;

		onTriggered: { this.parent.pollGamepads() }
	}

	Timer {
		interval: parent.eventPollingInterval;
		repeat: true;
		running: parent.gamepadChildrensCount;
		triggeredOnStart: true;

		onTriggered: { this.parent.gpButtonCheckLoop() }
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

			gpItem.poll(gp)
		}
	}

	gamepadConnectedHandler(event): {
		log('connected', event.gamepad.id)
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
