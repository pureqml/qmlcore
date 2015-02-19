Rectangle {
	id: progressBarItem;
	property real progress: 0.0;
	height: 6;
	width: 100;
	color: "#707070";

	Rectangle {
		anchors.left: parent.left;
		anchors.top: parent.top;
		height: parent.height;
		width: parent.width * progressBarItem.progress;
		gradient: Gradient {
			GradientStop { color: "#f2c300"; position: 0.0; }
			GradientStop { color: "#e89500"; position: 1.0; }
		}

		Behavior on width { Animation { duration: 300; } }
	}

}
