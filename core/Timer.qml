/// class handles periodic tasks
Object {
	signal triggered;					///< this signal triggered when timer fires
	property int interval: 1000;		///< interval, ms
	property bool repeat;				///< makes this timer periodic
	property bool running;				///< current timer status, true - running, false - paused
	property bool triggeredOnStart;		///< fire timer's signal on start or activation

	constructor: {
		this._trigger = this._context.wrapNativeCallback(this.triggered.bind(this))
	}

	/// restart timer, activate if stopped
	restart: { this.stop(); this.start(); }

	/// stops timer
	stop: { this.running = false }

	/// starts timer
	start: { this.running = true }

	/// @private
	onTriggered: {
		if (!this.repeat && (!this.triggeredOnStart || this._triggered))
			this.running = false
		this._triggered = true
	}

	/// @private
	onCompleted: {
		if (this.running && this.triggeredOnStart)
			this.triggered()
	}

	onRunningChanged: {
		this._restart()
		if (value && this.triggeredOnStart) {
			this._triggered = false
			this.triggered()
		}
	}

	onIntervalChanged,
	onRepeatChanged: { this._restart() }

	/// @private
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
		var self = this
		var context = self._context
		if (this.repeat)
			this._interval = setInterval(this._trigger, this.interval);
		else
			this._timeout = setTimeout(this._trigger, this.interval);
	}
}
