Item {
	property bool active;
	property string name;

	start: {
		this.visible = true;
		this.active = true;
		this.forceActiveFocus();
		console.log ("Activity started: ", this.name);
	}

	stop: {
		this.active = false;
		console.log ("Activity stopped: ", this.name);
	}

	onBackPressed: {
		if (this.active)
			this.stop();
	}
}