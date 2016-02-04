Object {
	signal triggered;

	property int interval: 1000;
	property bool repeat;
	property bool running;
	property bool triggeredOnStart;

	restart:	{ this._restart(); this.running = true; }
	stop:		{ this.running = false; }

	start: {
		var oldRunning = this.running;
		this.running = true;
		if (this.triggeredOnStart && !oldRunning)
			this._emitTriggered();
	}

	onCompleted: {
		if (this.running && this.triggeredOnStart)
			this.triggered()
	}
}
