Item {
	id: controlsProto;
	signal fullscreenToggled;
	signal volumeUpdated;
	signal pauseActivated;
	signal playActivated;
	property bool showFullscreenButton:	true;
	property bool showVolumeButton:		true;
	property bool showChannelControl:	true;
	property bool showMute:				false;
	property bool paused:				false;
	property int spacing: width / 24;
	property float volume;

	Image {
		anchors.centerIn: parent;
		source: "res/pause.png";
		visible: parent.paused;
	}

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

		onClicked: {
			if (this.parent.paused)
				controlsProto.playActivated()
			else
				controlsProto.pauseActivated()
		}
	}

	MuteIcon {
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.margins: 20;
		visible: parent.showMute;
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
		visible: parent.showChannelControl && renderer.fullscreen;
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
		channelControl.visible = this.showChannelControl && renderer.fullscreen;
		hideControlsTimer.restart();
	}

	onVisibleChanged: {
		if (this.visible)
			this.show();
	}
}
