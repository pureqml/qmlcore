Item {
	property bool active;
	property string name;
	signal started;
	signal stopped;

	isActivity(obj): { return obj instanceof qml.controls.Activity; }

	closeAll: {
		var childrens = this.parent.children;
		for (var i in childrens)
			if (this != childrens[i] && this.isActivity(childrens[i]))
				childrens[i].stop();
	}

	start: {
		if (this.active)
			return;

		if (this.parent && this.isActivity(this.parent))
			this.closeAll();

		this.started();
		this.visible = true;
		this.active = true;
		this.forceActiveFocus();
		log ("Activity started: ", this.name);
	}

	stop: {
		if (this.active) {
			this.active = false;
			this.stopped();
			log ("Activity stopped: ", this.name);
		}
	}

	onBackPressed: {
		if (this.active)
			this.stop();
		else
			event.accepted = false;
	}
}
