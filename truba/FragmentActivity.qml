Activity {
	property string originalLocation;

	isActivity(obj): { return obj instanceof qml.controls.Activity || obj instanceof qml.truba.FragmentActivity; }

	onStarted: {
		this.originalLocation = window.location.href.substring(0, window.location.href.length);
		window.location.href += "#" + this.name;
		log("Change location to: " + window.location.href);

	}

	onStopped: {
//		window.location.href = this.originalLocation; //this one causes page reload 
		log("Change location to: " + window.location);
	}

	updateLocation: { 
		if (window.location.href === this.originalLocation)
			this.stop();
	}

	onCompleted: {
		var self = this;
		$(window).on('popstate', function(e) {
			if (self.active)
				self.updateLocation();
		});
	}
}
