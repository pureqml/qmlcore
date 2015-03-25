Item {
	id: infoPanelProto;
	signal menuCalled;
	property color	channelColor;
	property string	channelIcon;
	property string	channelName;
	property int	channelNumber;
	property bool	active;
	name: "infoPanel";
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

	BaseButton {
		id: options;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		height: 100;
		width: 100;

		Text {
			anchors.centerIn: parent;
			text: "Options";
			color: "white";
		}

		onRightPressed: { channelInfo.forceActiveFocus(); }
		onLeftPressed: { programInfo.forceActiveFocus(); }
	}

	fillChannelInfo(channel): {
		if (!channel) {
			log("InfoPanel: Empty channel info.");
			return;
		}

		this.channelIcon = channel.source;
		this.channelColor = channel.color;
		this.channelNumber = channel.lcn ? channel.lcn : 0;
		this.channelName = channel.lcn ? this.channelNumber + ". " : "";
		this.channelName += channel.text;
	}

	onActiveFocusChanged:	{ channelInfo.forceActiveFocus(); }
	onActiveChanged:		{ hideTimer.active = this.active; }
	onBluePressed:			{ this.active = !this.active; }

	Behavior on opacity	{ Animation { duration: 300; } }
}
