Item {
	id: infoPanelProto;
	signal menuCalled;
	signal volumeUpdated;
	property color	channelColor;
	property string	channelIcon;
	property string	channelName;
	property int	channelNumber;
	property bool	active;
	property float	volume;
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

	FocusablePanel {
		id: options;
		property int spacing: (100 - volumeIcon.height) / 2;
		height: activeFocus ? 100 + spacing + volumeTrackBar.height : 100;
		width: 100;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		clip: true;

		TrackBar {
			id: volumeTrackBar;
			anchors.horizontalCenter: parent.horizontalCenter;
			anchors.bottom: volumeIcon.top;
			anchors.bottomMargin: options.spacing;
			visible: parent.activeFocus;

			onValueChanged: { infoPanelProto.volumeUpdated(this.value); }
		}

		Image {
			id: volumeIcon;
			anchors.horizontalCenter: parent.horizontalCenter;
			anchors.bottom: parent.bottom;
			anchors.bottomMargin: options.spacing;
			source: infoPanelProto.volume > 0.6 ? "res/volume.png" : infoPanelProto.volume > 0.3 ? "res/volume_mid.png" : "res/volume_min.png";
		}

		onRightPressed:	{ channelInfo.forceActiveFocus(); }
		onLeftPressed:	{ programInfo.forceActiveFocus(); }
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
	onVolumeChanged:		{ volumeTrackBar.value = infoPanelProto.volume; }

	Behavior on opacity	{ Animation { duration: 300; } }
}
