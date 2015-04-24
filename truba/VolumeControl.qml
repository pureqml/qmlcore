Item {
	id: volumeButton;
	signal volumeUpdated;
	property float volume;
	visible: parent.showVolumeButton;

	MouseArea {
		id: volumeControlArea;
		height: volumeInnerButton.height + volumeTrackBar.height;
		anchors.bottom: parent.bottom;
		anchors.left: volumeInnerButton.left;
		anchors.right: volumeInnerButton.right;
		hoverEnabled: true;
	}

	Rectangle {
		property int maxHeight: volumeTrackBar.height + volumeInnerButton.height / 2 + 35;
		height: volumeInnerButton.containsMouse || volumeTrackBar.containsMouse || volumeControlArea.containsMouse ? maxHeight : 0;
		width: 50;
		anchors.horizontalCenter: volumeInnerButton.horizontalCenter;
		anchors.bottom: volumeInnerButton.top;
		anchors.bottomMargin: -volumeInnerButton.height / 2;
		clip: true;
		radius: width / 2;
		color: "#fff";

		TrackBar {
			id: volumeTrackBar;
			width: 50;
			anchors.horizontalCenter: parent.horizontalCenter;
			anchors.top: parent.top;
			anchors.topMargin: 25;

			onValueChanged: { this.parent.volumeUpdated(this.value); }
		}

		Behavior on height { Animation { duration: 300; } }
	}

	RoundButton {
		id: volumeInnerButton;
		anchors.bottom: parent.bottom;
		anchors.right: parent.right;
		icon: parent.volume > 0.6 ? "res/volume.png" : parent.volume > 0.3 ? "res/volume_mid.png" : "res/volume_min.png";
	}
}
