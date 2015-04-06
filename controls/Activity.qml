Item {
	property bool active;
	property bool hasAnyActiveChild: false;
	property string currentActivity: "";
	property string name;
	signal started;
	signal stopped;

	isActivity(obj): { return obj instanceof qml.controls.Activity; }

	isAnyActiveInContext: {
		var childrens = this.parent.children;
		for (var i in childrens)
			if (this != childrens[i] && this.isActivity(childrens[i]))
				if (childrens[i].active)
					return true;
		return false;
	}

	closeAll: {
		var childrens = this.children;
		for (var i in childrens)
			if (this != childrens[i] && this.isActivity(childrens[i]))
				childrens[i].stop();
	}

	closeParentActivities: {
		var childrens = this.parent.children ? this.parent.children : this.children;
		for (var i in childrens)
			if (this != childrens[i] && this.isActivity(childrens[i]))
				childrens[i].stop();
	}

	start: {
		if (this.active)
			return;

		if (this.parent && this.isActivity(this.parent)) {
			this.closeParentActivities();
			this.parent.hasAnyActiveChild = true;
			this.parent.currentActivity = this.name;
		}

		this.started();
		this.visible = true;
		this.active = true;
		this.forceActiveFocus();
		log("Activity started: ", this.name);
	}

	stop: {
		if (!this.active)
			return;

		if (this.parent && this.isActivity(this.parent)) {
			this.parent.currentActivity = "";
			this.parent.hasAnyActiveChild = this.isAnyActiveInContext();
		}

		this.active = false;
		this.stopped();
		log("Activity stopped: ", this.name);
	}

	onBackPressed: {
		if (this.active)
			this.stop();
		else
			event.accepted = false;
	}
}
