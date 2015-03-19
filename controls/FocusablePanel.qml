MouseArea {
	focus: true;
	smooth: true;
	clip: true;
	property Color color: (activeFocus && !focusOnHover) || containsMouse ? colorTheme.activeBackgroundColor : colorTheme.backgroundColor;
	hoverEnabled: recursiveVisible;
	property real radius;
	property bool focusOnHover: false;
	property bool blink: false;

	Rectangle {
		anchors.fill: parent;
		color: parent.color;
		radius: parent.radius;
		border.width: 1;
		border.color: "#75757575";
		anchors.margins: 1;

		Rectangle {
			anchors.centerIn: parent;
			height: parent.height;
			color: "#FF9800";
			radius: parent.radius;
			width: parent.width;//parent.parent.blink ? parent.width - 2 : 0;
			opacity: parent.parent.blink ? 1 : 0;

			Behavior on color	{ ColorAnimation { duration: 250; } }
			Behavior on width	{ Animation { duration: 150; } }
			Behavior on opacity	{ Animation { duration: 150; } }
		}

		Behavior on color	{ ColorAnimation { duration: 250; } }
	}

	makeBlink: {
		this.blink = true;
		blinkTimer.restart();
	}

	Timer {
		id: blinkTimer;
		interval: 150;
		running: true;

		onTriggered: {
			this.parent.blink = false;
		}
	}

	onEntered: { 
		if (!this.activeFocus)
			this.forceActiveFocus(); 
	}

	Behavior on opacity	{ Animation { duration: 250; } }
	Behavior on height	{ Animation { duration: 250; } }
}
