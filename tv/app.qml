Item {
	id: mainWindow;
	anchors.fill: renderer;
	anchors.leftMargin: 200;
	anchors.topMargin: 100;

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
		anchors.centerIn: parent;
	}

	Image {
		id: img;
		anchors.centerIn: parent;
		source: "http://svalko.org/data/2015_02_09_15_54cs625418_vk_me_v625418936_1e700_MscWY8T2f7Y.jpg";
		onStatusChanged: {
			console.log("status = " + this.status, this.paintedWidth, this.paintedHeight);
		}
		z: -5;
	}

	Rectangle {
		id: rect4;
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
