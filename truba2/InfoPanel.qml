Rectangle {
	id: infoPanelProto;
	property variant channel;
	width: renderer.width - 50;
	height: 120;
	visible: false;
	color: colorTheme.activeDialogBackground;

	Rectangle {
		id: channelBackground;
		width: height;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.bottom: parent.bottom;

		Image {
			id: channelLogoImage;
			anchors.fill: parent;
			anchors.margins: 30;
		}
	}

	Rectangle {
		id: progressRect;
		property real progress: 0.0;
		width: (parent.width - channelBackground.width) * progress;
		height: parent.height / 10;
		color: colorTheme.accentColor;
		anchors.left: channelBackground.right;
		anchors.bottom: parent.bottom;

		Behavior on width { Animation { duration: 300; } }
	}

	Text {
		id: channelTitleText;
		anchors.top: parent.top;
		anchors.left: channelBackground.right;
		anchors.topMargin: 5;
		anchors.leftMargin: 10;
		color: colorTheme.accentTextColor;
		font.pixelSize: 18;
	}

	Text {
		id: programTimeText;
		anchors.top: channelTitleText.bottom;
		anchors.left: channelTitleText.left;
		anchors.topMargin: 5;
		color: colorTheme.activeTextColor;
		opacity: 0.6;
		font.pixelSize: 14;
	}

	Text {
		id: programTitleText;
		anchors.top: channelTitleText.bottom;
		anchors.left: programTimeText.right;
		anchors.topMargin: 5;
		anchors.leftMargin: 10;
		color: colorTheme.activeTextColor;
		font.pixelSize: 14;
	}

	Timer {
		interval: 3000;
		running: infoPanelProto.visible;
		repeat: running;

		onTriggered: { infoPanelProto.updateProgress(); }
	}

	setChannel(channel): {
		this.channel = channel
		channelTitleText.text = channel.text
		channelLogoImage.source = channel.source
		channelBackground.color = channel.color
		if (channel.program.title) {
			programTimeText.text = channel.program.start + "-" + channel.program.stop
			programTitleText.text = channel.program.title
			this.updateProgress()
		} else {
			programTimeText.text = ""
			programTitleText.text = ""
			progressRect.progress = 0.0
		}
	}

	updateProgress: {
		var channel = this.channel
		if (channel.program.startTime) {
			var currDate = new Date();
			var start = channel.program.startTime
			var stop = channel.program.stopTime
			progressRect.progress = (currDate.getTime() - start.getTime()) / (stop.getTime() - start.getTime())
		}
	}

	hide: { this.visible = false; }

	show: {
		if (this.channel)
			this.visible = true;
	}
}
