Item {
	signal fullscreenToggled;
	signal volumeUpdated;
	property bool showFullscreenButton:	true;
	property bool showVolumeButton:		true;
	property bool showChannelControl:	true;
	property float volume;

	MouseArea {
		anchors.fill: parent;
		hoverEnabled: !parent.parent.hasAnyActiveChild;

		onMouseXChanged: {
			if (this.hoverEnabled)
				this.parent.show();
		}

		onMouseYChanged: {
			if (this.hoverEnabled)
				this.parent.show();
		}
	}

	RoundButton {
		id: fullscreenButton;
		anchors.bottom: parent.bottom;
		anchors.right: parent.right;
		anchors.rightMargin: 54;
		anchors.bottomMargin: 47;
		icon: "res/fullscreen.png";
		visible: parent.showFullscreenButton;

		onToggled: { this.parent.fullscreenToggled(); }
	}

	VolumeControl {
		id: volumeButton;
		visible: parent.showVolumeButton;
		anchors.bottom: parent.bottom;
		anchors.right: fullscreenButton.left;
		anchors.rightMargin: 24;
		anchors.bottomMargin: 47;
		volume: parent.volume;

		onVolumeUpdated(value): { this.parent.volumeUpdated(value); }
	}

	ChannelControl {
		id: channelControl;
		width: 150;
		anchors.bottom: parent.bottom;
		anchors.left: parent.left;
		anchors.leftMargin: 54;
		anchors.bottomMargin: 47;
		visible: parent.showChannelControl;
	}

	Timer {
		id: hideControlsTimer;
		interval: 5000;	

		onTriggered: {
			fullscreenButton.visible = false;
			listsButton.visible = false;
			volumeButton.visible = false;
			channelControl.visible = false;
		}
	}

	setChannelInfo(channel): { channelControl.setChannelInfo(channel); }
	setProgramInfo(program): { channelControl.setProgramInfo(program); }

	show: {
		fullscreenButton.visible = this.showFullscreenButton;
		volumeButton.visible = this.showVolumeButton;
		channelControl.visible = this.showChannelControl;
		hideControlsTimer.restart();
	}

	onVisibleChanged: {
		if (this.visible)
			this.show();
	}
}
