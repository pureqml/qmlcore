Activity {
	property string originalLocation;

	isActivity(obj): { return obj instanceof qml.controls.Activity || obj instanceof qml.truba.FragmentActivity; }

	onStarted: {
		this.originalLocation = window.location.href.substring(0, window.location.href.length);
		window.location.href += "#" + this.name;
		log("Change location to: " + window.location.href);

	}

	onStopped: {
		if (window.location.href != this.originalLocation) {
			window.location.href = this.originalLocation;
			log("Change location to: " + window.location);
		}
	}

	updateLocation: { 
		if (window.location.href === this.originalLocation)
			this.stop();
	}

	onCompleted: {
		if (!this.parent.parent && window.location.href.indexOf(this.name) < 0) {
			this.originalLocation = window.location.href.substring(0, window.location.href.length);
			window.location.href += "#" + this.name;
			log("Change location to: " + window.location.href);
		}
		var self = this;
		$(window).on('popstate', function(e) {
			if (self.active)
				self.updateLocation();
		});
	}
}
