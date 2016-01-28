Rectangle {
	id: octoPlayControlProto;
	property string icon;
	property bool pressed;
	width: 50;
	height: width;
	radius: width / 2;
	color: activeFocus ? "#fff" : "#fff0";
	focus: true;

	Rectangle {
		id: blinck;
		color: "#0000";
		anchors.fill: parent;
		radius: parent.radius;

		Behavior on color { ColorAnimation { duration: 300; } }
	}

	Image {
		anchors.centerIn: parent;
		source: "res/octoosd/controls/" + (octoPlayControlProto.activeFocus ? "b_" : "") + octoPlayControlProto.icon;
	}

	onPressedChanged: {
		if (!this.pressed)
			return

		blinck.color = "#000"
		//controlColorAnim.complete()
		blinck.color = "#0000"
		this.pressed = false
	}

	Behavior on color { ColorAnimation { duration: 300; } }
}
