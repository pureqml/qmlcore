Item {
	property bool active;

	start: {
		this.visible = true;
		this.active = true;
		this.forceActiveFocus();
	}

	stop: {
		this.active = false;
	}

	onBackPressed: {
		if (this.active)
			this.stop();
	}
}