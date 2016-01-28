Item {
	id: octoVolumeProto;
	property int value: 0;
	property int shift: 5;
	property int maxVolume: 100;
	property int stateInterval: maxVolume / 3;
	property string volumeState: value >= maxVolume - stateInterval ? "2" : (value >= maxVolume - 2 * stateInterval ? "1" : "0");
	property bool showed: false;
	width: volumeIcon.paintedWidth + 50;
	height: volumeIcon.paintedHeight;
	focus: false;
	visible: showed;

	Image {
		id: volumeIcon;
		anchors.left: parent.left;
		anchors.verticalCenter: parent.verticalCenter;
		source: "res/octoosd/controls/volume/vol_" + octoVolumeProto.volumeState + ".png";
	}

	Text {
		id: volumeValueText;
		anchors.left: volumeIcon.right;
		anchors.verticalCenter: parent.verticalCenter;
		anchors.leftMargin: 10;
		color: octoColors.textColor;
		//font: mainFont;
	}

	Timer {
		id: showVolumeTimer;
		duration: 3000;

		//onTriggered: { octoVolumeProto.showed = false }
	}

	volumeUp: {
		this.value = this.value + this.shift > this.maxVolume ? this.maxVolume : this.value + this.shift
		//mainWindow.volumeUp()
	}

	volumeDown: {
		this.value = this.value - this.shift < 0 ? 0 : this.value - this.shift
		//mainWindow.volumeDown()
	}

	onValueChanged: {
		volumeValueText.text = this.value.toString()
		this.showed = true
		showVolumeTimer.restart()
	}

	//onCompleted: { this.value = mainWindow.getVolume() }
}
