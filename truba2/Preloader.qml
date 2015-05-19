Item {
	width: 100;
	height: 100;
	property bool small: false;

	Rectangle {
		id: preloadCircle;
		width: parent.small ? 100 : 10;
		height: width;
		color: "#fff";
		radius: parent.width / 2;
		anchors.centerIn: parent;

		Behavior on width { Animation { duration: 300; } }
	}

	Timer {
		interval: 1000;
		running: parent.visible;
		repeat: true;

		onTriggered: { this.parent.small = !this.parent.small; }
	}
}
