Text {
	updateText: {
		var now = new Date();
		var minutes = now.getMinutes();
		minutes = minutes >= 10 ? minutes : "0" + minutes
		this.text = now.getHours() + ":" + minutes
	}

	Timer {
		duration: 1000;
		running: true;
		repeat: parent.recursiveVisible;

		onTriggered: {
			this.parent.updateText();
		}
	}
}