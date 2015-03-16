Activity {
	name: "infoPanel";
	opacity: active ? 1.0 : 0.0;
	signal menuCalled;

	Timer {
		id: hideTimer;
		interval: 10000;
		running: true;

		onTriggered: {
			this.parent.stop();
		}
	}

	FocusablePanel {
		id: channelInfo;
		anchors.left: parent.left;
		anchors.bottom: parent.bottom;
		height: activeFocus ? 200 : 100;
		width: 240;

		onRightPressed: { programInfo.forceActiveFocus(); }
		onLeftPressed: { options.forceActiveFocus(); }
	}

	FocusablePanel {
		id: programInfo;
		anchors.left: channelInfo.right;
		anchors.right: options.left;
		anchors.leftMargin: 8;
		anchors.rightMargin: 8;
		anchors.bottom: parent.bottom;
		height: activeFocus ? 200 : 100;

		onRightPressed: { options.forceActiveFocus(); }
		onLeftPressed: { channelInfo.forceActiveFocus(); }
	}

	FocusablePanel {
		id: options;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		height: 100;
		width: 100;

		onRightPressed: { channelInfo.forceActiveFocus(); }
		onLeftPressed: { programInfo.forceActiveFocus(); }
	}

	onActiveChanged: {
		if (this.active)
			hideTimer.restart();
		else
			hideTimer.stop();
		channelInfo.forceActiveFocus();
	}

	onBluePressed: {
		if (this.active)
			this.stop();
		else
			this.start();
	}

	Behavior on opacity	{ Animation { duration: 300; } }
}