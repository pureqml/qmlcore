Object {
	signal triggered;

	property int interval: 1000;
	property bool repeat;
	property bool running;
	property bool triggeredOnStart;

	restart:	{ this._restart(); this.running = true; }
	stop:		{ this.running = false; }

	onTriggered: { if (!this.repeat) this.running = false }

	start: {
		var oldRunning = this.running;
		this.running = true;
		if (this.triggeredOnStart && !oldRunning)
			this._emitTriggered();
	}

	onRunningChanged: {
		if (value && this.triggeredOnStart)
			this.triggered()
	}

	onCompleted: {
		if (this.running && this.triggeredOnStart)
			this.triggered()
	}

	function _update(name, value) {
		switch(name) {
			case 'running': this._restart(); break;
			case 'interval': this._restart(); break;
			case 'repeat': this._restart(); break;
		}
		qml.core.Object.prototype._update.apply(this, arguments);
	}

	function _restart() {
		if (this._timeout) {
			clearTimeout(this._timeout);
			this._timeout = undefined;
		}
		if (this._interval) {
			clearTimeout(this._interval);
			this._interval = undefined;
		}

		if (!this.running)
			return;

		//log("starting timer", this.interval, this.repeat);
		var self = this;
		if (this.repeat)
			this._interval = setInterval(function() { self.triggered(); }, this.interval);
		else
			this._timeout = setTimeout(function() { self.triggered(); }, this.interval);
	}

}
