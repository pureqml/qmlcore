///gamepad manager item holds Gamepad items and provide common API
Item {
	signal connected;		///< emitted when any gamepad is connected
	signal disconnected;	///< emitted when gamepad is disconnected

	property variant _gamepads;	///< @private
	property int count: 0;						///< count of the all connected gamepad devices
	property int gamepadChildrensCount: 0;		///< count of Gamepad instances inside scope
	property int gamepadPollingInterval: 1000;	///< startup delay before gamepads polling because there is no gamepad events
	property int eventPollingInterval: 8;		///< gamepad event polling timer interval default value is 8ms (for 120fps) because there is no gamepad events

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

	/// @private
	pollGamepads: {
		clearInterval(this._gpPollInterval)
		var gamepads = navigator.getGamepads ? navigator.getGamepads() : (navigator.webkitGetGamepads ? navigator.webkitGetGamepads : []);
		for (var i = 0; i < gamepads.length; ++i) {
			var gamepad = gamepads[i]
			if (gamepad)
				this.gamepadConnectedHandler({ 'gamepad': gamepad })
		}
	}

	/// @private
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
				if (c instanceof $core.Gamepad && c.connected && c.index === gp.index) {
					gpItem = c
					break
				}
			}

			if (!gp || !gpItem)
				continue

			gpItem.poll(gp)
		}
	}

	/// @private
	gamepadConnectedHandler(event): {
		log('connected', event.gamepad.id)
		this.connected(event.gamepad)

		if (!this._gamepads)
			this._gamepads = {}
		this._gamepads[event.gamepad.index] = event.gamepad
		++this.count

		if (!$core.Gamepad) {
			log("No 'Gamepad' instance found, add at least one 'Gamepad' item inside 'GamepadManager' scope.")
			return
		}

		var vendorRegExp = /vendor.*?\d{1,4}/g
		var productRegExp = /product.*?\d{1,4}/g
		var digits = /\d{1,4}/g

		var idStr = event.gamepad.id.toLowerCase()
		var match = vendorRegExp.exec(idStr)
		match = digits.exec(match)
		var vendorId
		if (match && match.length)
			vendorId = match[0]

		match = productRegExp.exec(idStr)
		match = digits.exec(match)
		var productId
		if (match && match.length)
			productId = match[0]

		var children = this.children
		var g = event.gamepad
		for (var i = 0; i < children.length; ++i) {
			var c = children[i]
			if (c instanceof $core.Gamepad && !c.connected) {
				c.index = g.index
				c.connected = true
				c.deviceInfo = g.id
				c.buttonsCount = g.buttons.length
				c.axesCount = g.axes.length
				if (vendorId)
					c.vendorId = vendorId
				if (productId)
					c.productId = productId
				c.standartMapping = g.mapping === "standard"
				++this.gamepadChildrensCount
				break
			}
		}
	}

	/// @private
	gamepadDisconnectedHandler(event): {
		this.disconnected(event.gamepad)
		delete this._gamepads[event.gamepad.index]
		--this.count

		if (!$core.Gamepad) {
			log("No 'Gamepad' instance found, add at least one 'Gamepad' item inside 'GamepadManager' scope.")
			return
		}

		var g = event.gamepad
		var children = this.children

		for (var i = 0; i < children.length; ++i) {
			var c = children[i]
			if (c instanceof $core.Gamepad && c.index === g.index) {
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

	/// @private
	onCompleted: {
		this._gpButtonsPollInterval = {}
		this._gpPollInterval = {}

		startupTimer.restart()

		var ctx = this._context
		ctx.window.on('gamepadconnected', this.gamepadConnectedHandler.bind(this))
		ctx.window.on('gamepaddisconnected', this.gamepadDisconnectedHandler.bind(this))
	}
}
