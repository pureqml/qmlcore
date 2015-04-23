Item {
	signal volumeUpdated;
	property float volume;

	id: volumeButton;
	visible: parent.showVolumeButton;
	anchors.bottom: parent.bottom;
	anchors.right: fullscreenButton.left;
	anchors.rightMargin: 24;
	anchors.bottomMargin: 47;

	Rectangle {
		height: volumeInnerButton.containsMouse || volumeTrackBar.containsMouse ? volumeTrackBar.height + volumeInnerButton.height / 2 + 35 : 0;
		width: 50;
		radius: width / 2;
		anchors.horizontalCenter: volumeInnerButton.horizontalCenter;
		anchors.bottom: volumeInnerButton.top;
		anchors.bottomMargin: -volumeInnerButton.height / 2;
		color: "#fff";

		Behavior on height { Animation { duration: 300; } }
	}

	TrackBar {
		id: volumeTrackBar;
		width: 50;
		anchors.horizontalCenter: volumeInnerButton.horizontalCenter;
		anchors.bottom: volumeInnerButton.top;
		anchors.bottomMargin: 10;
		opacity: volumeInnerButton.containsMouse || containsMouse ? 1.0 : 0.0;

		onValueChanged: { this.parent.volumeUpdated(this.value); }

		Behavior on opacity { Animation { duration: 300; } }
	}

	RoundButton {
		id: volumeInnerButton;
		anchors.bottom: parent.bottom;
		anchors.right: parent.right;
		icon: parent.volume > 0.6 ? "res/volume.png" : parent.volume > 0.3 ? "res/volume_mid.png" : "res/volume_min.png";
	}
}
