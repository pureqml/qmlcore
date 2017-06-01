Rectangle {
	property bool showGlow;
	anchors.fill: context;
	color: "#212121";

	Text {
		anchors.bottom: logo.top;
		anchors.horizontalCenter: parent.horizontalCenter;
		text: "powered by";
		font.weight: 300;
		font.pixelSize: 36;
		color: "#eee";
	}

	Image {
		anchors.centerIn: parent;
		source: "res/pureqml-splash-shadow.png";
		opacity: parent.showGlow ? 1.0 : 0.0;

		Behavior on opacity { Animation { duration: 3000; } }
	}

	Image {
		id: logo;
		anchors.centerIn: parent;
		source: "res/pureqml-splash-logo.png";
	}

	Timer {
		interval: 3000;
		triggeredOnStart: true;
		running: true;
		repeat: true;

		onTriggered: { this.parent.showGlow = !this.parent.showGlow }
	}
}
