Item {
	signal fullscreenToggled;
	signal listsToggled;
	signal volumeUpdated;
	property bool showListsButton: true;
	property bool showFullscreenButton: true;
	property bool showVolumeButton: true;
	property float volume;
	anchors.fill: renderer;

	MouseArea {
		anchors.fill: renderer;
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
		id: listsButton;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.leftMargin: 54;
		anchors.topMargin: 47;
		icon: "res/list.png";
		visible: parent.showListsButton;

		onToggled: { this.parent.listsToggled(); }
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

		onVolumeUpdated: { this.parent.volumeUpdated(); }
	}

	Timer {
		id: hideControlsTimer;
		interval: 5000;	

		onTriggered: {
			fullscreenButton.visible = false;
			listsButton.visible = false;
			volumeButton.visible = false;
		}
	}

	show: {
		fullscreenButton.visible = this.showFullscreenButton;
		listsButton.visible = this.showListsButton;
		volumeButton.visible = this.showVolumeButton;
		hideControlsTimer.restart();
	}

	onVisibleChanged: {
		if (this.visible)
			this.show();
	}
}
