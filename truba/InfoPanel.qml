Item {
	id: infoPanelProto;
	signal menuCalled;
	signal volumeDecreased;
	signal volumeIncreased;
	property color	channelColor;
	property string	channelIcon;
	property string	channelName;
	property int	channelNumber;
	property bool	active;
	opacity: active ? 1.0 : 0.0;

	Timer {
		id: hideTimer;
		interval: 10000;
		running: true;

		onTriggered: { this.parent.active = false; }
	}

	FocusablePanel {
		id: channelInfo;
		anchors.left: parent.left;
		anchors.bottom: parent.bottom;
		height: activeFocus ? 200 : 100;
		color: infoPanelProto.channelColor;
		width: 240;

		Image {
			anchors.centerIn: parent;
			source: infoPanelProto.channelIcon;
		}

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

		Text {
			anchors.top: parent.top;
			anchors.left: parent.left;
			anchors.margins: 10;
			text: infoPanelProto.channelName;
			font.pointSize: 24;
			color: colorTheme.textColor;
		}

		onRightPressed: { options.forceActiveFocus(); }
		onLeftPressed: { channelInfo.forceActiveFocus(); }
	}

	TextButton {
		id: options;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		height: activeFocus ? 200 : 100;
		focusOnHover: true;
		width: 100;

		Image {
			anchors.horizontalCenter: parent.horizontalCenter;
			anchors.top: parent.top;
			anchors.topMargin: 20;
			source: "res/nav_up.png";
			opacity: parent.activeFocus ? 1.0 : 0;

			Behavior on opacity	{ Animation { duration: 300; } }
		}

		Image {
			anchors.centerIn: parent;
			source: "res/volume.png";
		}

		MouseArea {
			anchors.fill: volumeDown;
			onClicked: { log("dsdsd"); }
		}

		Image {
			id: volumeDown;
			anchors.horizontalCenter: options.horizontalCenter;
			anchors.bottom: options.bottom;
			anchors.bottomMargin: 20;
			source: "res/nav_down.png";
			opacity: options.activeFocus ? 1.0 : 0;

			Behavior on opacity	{ Animation { duration: 300; } }
		}

		onRightPressed:	{ channelInfo.forceActiveFocus(); }
		onLeftPressed:	{ programInfo.forceActiveFocus(); }
		onUpPressed:	{ infoPanelProto.volumeIncreased(); }
		onDownPressed:	{ infoPanelProto.volumeDecreased(); }
	}

	fillChannelInfo(channel): {
		if (!channel) {
			log("InfoPanel: Empty channel info.");
			return;
		}

		this.channelIcon = channel.source;
		this.channelColor = channel.color;
		this.channelNumber = channel.lcn;
		this.channelName = this.channelNumber + ". " + channel.text;
	}

	onActiveFocusChanged:	{ channelInfo.forceActiveFocus(); }
	onActiveChanged:		{ hideTimer.active = this.active; }
	onBluePressed:			{ this.active = !this.active; }

	Behavior on opacity	{ Animation { duration: 300; } }
}
