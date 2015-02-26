Item {
	id: mouseProto;
	focus: false;
	enabled: false;
	opacity: 0.0;

	//TODO: replace it by considered icon.
	Item {
		Rectangle {
			width: 30;
			height: width / 2;
			color: "#f00";
			focus: false;
		}

		Rectangle {
			height: 30;
			width: height / 2;
			color: "#f00";
			focus: false;
		}
	}

	Timer {
		id: hideTimer;
		duration: 10000;

		onTriggered: { mouseProto.opacity = 0.0; }
	}

	onXChanged: { mouseProto.show(); }
	onYChanged: { mouseProto.show(); }

	show: {
		mouseProto.opacity = 1.0;
		hideTimer.restart();
	}

	Behavior on opacity { Animation { duration: 300; } }
}
