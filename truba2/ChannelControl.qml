Item {
	property string	channelIcon;
	property string	channelColor;
	property string	channelName;
	property string	programTitle;
	property bool	showInfo: false;

	Rectangle {
		id: programBackGround;
		height: channelControlInnerButton.height / 2;
		anchors.bottom: parent.bottom;
		anchors.left: parent.left;
		anchors.leftMargin: channelControlInnerButton.width / 2;
		radius: height / 2;
		color: colorTheme.backgroundColor;
		clip: true;

		Text {
			id: infoControlChannelText;
			anchors.left: channelControlInnerButton.right;
			anchors.top: parent.top;
			anchors.leftMargin: 20;
			anchors.topMargin: 5;
			font.pointSize: 18;
			text: parent.parent.channelName;
			color: colorTheme.textColor;
		}

		Text {
			id: infoControlProgramText;
			anchors.left: channelControlInnerButton.right;
			anchors.bottom: parent.bottom;
			anchors.leftMargin: 20;
			anchors.bottomMargin: 5;
			font.pointSize: 18;
			text: parent.parent.programTitle;
			color: colorTheme.textColor;
		}

		Behavior on width { Animation { duration: 300; } }
	}

	RoundButton {
		id: channelControlInnerButton;
		width: 150;
		anchors.bottom: parent.bottom;
		anchors.left: parent.left;
		icon: parent.channelIcon;
		color: parent.channelColor;

		onToggled: {
			var maxText = Math.max(infoControlProgramText.paintedWidth, infoControlChannelText.paintedWidth);
			maxText += channelControlInnerButton.height;

			this.parent.showInfo = !this.parent.showInfo;
			programBackGround.width = this.parent.showInfo ? Math.max(channelControlInnerButton.width * 3, maxText) : 0;
		}
	}

	setProgramInfo(program): {
		if (!program) {
			log("InfoPanel: Empty program info.");
			return;
		}
		this.programTitle = program.title;
	}

	setChannelInfo(channel): {
		this.channelIcon = "";
		this.channelColor = "";
		this.channelName = "";

		if (!channel) {
			log("InfoPanel: Empty channel info.");
			return;
		}

		this.channelIcon = channel.source;
		this.channelColor = channel.color;
		this.channelName = channel.text;
	}
}
