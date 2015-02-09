Item {
	x: 200;
	y: 100;

	Rectangle {
		id: rect1;
		width: 100;
		height: 100;
		color: "#f00";
		Behavior on x { Animation { duration: 1000; } }
	}

	Timer {
		running: true;
		interval: 500;
		repeat: true;

		property bool value;
		onTriggered: {
			this.value = !this.value; /*rect1*/ rect1.x = this.value? 400: 100;
			//c-comment
		}
	}

	Rectangle {
		id: rect2;
		width: 100;
		height: 100;
		x: 150;
		y: 100;
		color: "#0f0";
		radius: 20;

		border.width: 10;
		border.color: "#c80";
	}

	Rectangle {
		id: rect3;
		radius: 10;
		width: 100;
		height: 100;
		x: 300;
		color: "#00f";

		MouseArea {
			width: 100;
			height: 100;
			anchors.fill: parent;
			hoverEnabled: true;
			onEntered: { rect3.color = "#44f"; }
			onExited: { rect3.color = "#00f"; }
		}
	}

	Text {
		x: 200;
		y: 200;
		text: "Hello, world";
		font.pointSize: 32;
	}

	Rectangle {
		anchors.right: rect3.right;
		anchors.left: rect1.left;
		anchors.leftMargin: 20;
		anchors.rightMargin: 20;
		anchors.top: rect2.bottom;
		height: 30;
		z: -1;
		color: "#f0f";
	}
}
