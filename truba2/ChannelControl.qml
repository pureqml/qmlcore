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

		Column {
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.verticalCenter: parent.verticalCenter;
			spacing: parent.height - infoControlChannelText.height - infoControlProgramText.height / 3;

			Text {
				id: infoControlChannelText;
				anchors.left: channelControlInnerButton.right;
				anchors.leftMargin: 20;
				font.pointSize: 18;
				text: parent.parent.parent.channelName;
				color: colorTheme.textColor;
			}

			Text {
				id: infoControlProgramText;
				anchors.left: channelControlInnerButton.right;
				anchors.leftMargin: 20;
				font.pointSize: 18;
				text: parent.parent.parent.programTitle;
				color: colorTheme.textColor;
			}
		}

		Behavior on width { Animation { duration: 300; } }
	}

	RoundButton {
		id: channelControlInnerButton;
		width: parent.width;
		anchors.bottom: parent.bottom;
		anchors.left: parent.left;
		icon: parent.channelIcon;
		color: parent.channelColor;
		clip: true;

		onToggled: {
			var maxText = Math.max(infoControlProgramText.paintedWidth, infoControlChannelText.paintedWidth);
			maxText += channelControlInnerButton.height;

			this.parent.showInfo = !this.parent.showInfo;
			programBackGround.width = this.parent.showInfo ? Math.max(channelControlInnerButton.width * 3, maxText) : 0;
		}
	}

	Image {
		anchors.fill: channelControlInnerButton;
		source: "res/blick.png";

	}

	MouseArea {
		anchors.fill: channelControlInnerButton;
		hoverEnabled: true;

		onClicked: {
			if (renderer.fullscreen)
				channelControlInnerButton.toggled();
		}
	}

	setChannelInfo(channel): {
		this.channelIcon = "";
		this.channelColor = "#fff";
		this.channelName = "";

		if (!channel) {
			log("InfoPanel: Empty channel info.");
			return;
		}

		this.channelIcon = channel.source;
		this.channelColor = channel.color;
		this.channelName = channel.text;
		this.programTitle = channel.program.title != undefined ? channel.program.title : "";
	}
}
