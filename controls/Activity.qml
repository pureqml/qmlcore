Item {
	property bool active;
	property string name;
	signal started;
	signal stopped;

	start: {
		if(!this.active) {
			this.started();
			this.visible = true;
			this.active = true;
			this.forceActiveFocus();
			console.log ("Activity started: ", this.name);
		}
	}

	stop: {
		if (this.active) {
			this.active = false;
			this.stopped();
			console.log ("Activity stopped: ", this.name);
		}
	}

	onBackPressed: {
		if (this.active)
			this.stop();
	}
}