Item {
	signal fullscreenToggled;
	signal volumeUpdated;
	property bool showFullscreenButton:	true;
	property bool showVolumeButton:		true;
	property bool showChannelControl:	true;
	property int spacing: width / 24;
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
		width: parent.width / 14;
		anchors.bottom: parent.bottom;
		anchors.right: parent.right;
		anchors.rightMargin: parent.spacing;
		anchors.bottomMargin: parent.spacing;
		icon: "res/fullscreen.png";
		visible: parent.showFullscreenButton;

		onToggled: { this.parent.fullscreenToggled(); }
	}

	VolumeControl {
		id: volumeButton;
		width: parent.width / 14;
		visible: parent.showVolumeButton;
		anchors.bottom: parent.bottom;
		anchors.right: fullscreenButton.left;
		anchors.rightMargin: parent.spacing;
		anchors.bottomMargin: parent.spacing;
		volume: parent.volume;

		onVolumeUpdated(value): { this.parent.volumeUpdated(value); }
	}

	ChannelControl {
		id: channelControl;
		width: parent.width / 8;
		anchors.bottom: parent.bottom;
		anchors.left: parent.left;
		anchors.leftMargin: parent.spacing;
		anchors.bottomMargin: parent.spacing;
		visible: parent.showChannelControl;
	}

	Timer {
		id: hideControlsTimer;
		interval: 5000;	

		onTriggered: {
			fullscreenButton.visible = false;
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
