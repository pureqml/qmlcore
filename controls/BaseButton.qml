FocusablePanel {
	signal triggered;
	property bool blink: false;
	clip: true;

	Rectangle {
		anchors.centerIn: parent;
		height: parent.height;
		width: parent.width;//parent.parent.blink ? parent.width - 2 : 0;
		color: "#FF9800";
		radius: parent.radius;
		opacity: parent.blink ? 1 : 0;

		Behavior on opacity	{ Animation { duration: 150; } }
	}

	Timer {
		id: blinkTimer;
		interval: 150;
		running: true;

		onTriggered: {
			this.parent.blink = false;
		}
	}

	makeBlink: {
		this.blink = true;
		blinkTimer.restart();
	}

	onSelectPressed: { 
		this.makeBlink();
		this.triggered(); 
		event.accepted = false;
	}

	onClicked: { 
		this.makeBlink();
		this.triggered(); 
	}	
}
