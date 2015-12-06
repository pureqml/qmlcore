Item {
	id: channelInfoPanelProto;
	signal isAlive;
	signal switched;
	signal rejected;
	property variant channel;
	visible: false;
	focus: visible;

	Rectangle {
		id: fog;
		anchors.fill: renderer;
		//color: utils.lighter(logoBg.color, 0.4);
		color: "#0000";
		opacity: parent.visible ? 1.0 : 0.0;

		Behavior on opacity { Animation { duration: 300; } }
	}

	Rectangle {
		anchors.fill: parent;
		color: colorTheme.activePanelColor;
	}

	Rectangle {
		id: logoBg;
		anchors.fill: selectedChannelLogo;
	}

	Image {
		id: selectedChannelLogo;
		anchors.top: parent.top;
		anchors.left: parent.left;
	}

	Text {
		id: channelInfoTitle;
		anchors.top: parent.top;
		anchors.left: selectedChannelLogo.right;
		anchors.right: parent.right;
		anchors.margins: 10;
		color: colorTheme.accentTextColor;
		clip: true;
		font.pixelSize: 18;
	}

	Text {
		id: currentProgramText;
		anchors.left: logoBg.right;
		anchors.right: parent.right;
		anchors.bottom: currentProgress.top;
		anchors.margins: 10;
		color: colorTheme.activeTextColor;
		clip: true;
		font.pixelSize: 14;
	}

	Item {
		anchors.left: logoBg.right;
		anchors.right: parent.right;
		anchors.bottom: logoBg.bottom;
		anchors.leftMargin: 10;
		anchors.rightMargin: 10;

		Rectangle {
			id: currentProgress;
			property real progress: 0.0;
			height: 10;
			width: progress * parent.width;
			anchors.left: parent.left;
			anchors.bottom: parent.bottom;
			color: colorTheme.accentColor;
		}
	}

	Rectangle {
		anchors.fill: programsList;
		color: "#0003";
	}

	ListView {
		id: programsList;
		width: parent.width / 2;
		anchors.top: logoBg.bottom;
		anchors.left: parent.left;
		anchors.bottom: parent.bottom;
		anchors.margins: 10;
		clip: true;
		model: epgModel;
		delegate: EPGDelegate { }

		onRightPressed: { acceptedButton.forceActiveFocus(); }

		onActiveFocusChanged: {
			if (this.activeFocus)
				programDescription.updateDescription()
		}

		onCurrentIndexChanged: { programDescription.updateDescription(); }
	}

	Text {
		id: programDescription;
		anchors.top: programsList.top;
		anchors.left: programsList.right;
		anchors.right: parent.right;
		anchors.bottom: acceptedButton.top;
		anchors.leftMargin: 10;
		anchors.rightMargin: 10;
		wrapMode: Text.Wrap;
		color: colorTheme.activeTextColor;

		updateDescription: { this.text = programsList.model.get(programsList.currentIndex).description }
	}

	Button {
		id: acceptedButton;
		anchors.left: programsList.right;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		anchors.margins: 10;
		text: "Телесмотреть";

		onLeftPressed: { programsList.forceActiveFocus() }

		onSelectPressed: {
			//if (!this.visible)
				//return false;
			channelInfoPanelProto.switched(channelInfoPanelProto.channel);
			channelInfoPanelProto.hide();
		}
	}

	Timer {
		interval: 3000;
		running: channelInfoPanelProto.visible;
		repeat: channelInfoPanelProto.visible;

		onTriggered: {
			channelInfoPanelProto.isAlive()
			channelInfoPanelProto.updateProgress()
		}
	}

	onVisibleChanged: {
		if (this.visible)
			acceptedButton.forceActiveFocus()
	}

	show(channel): {
		this.visible = true
		this.channel = channel

		//this.x = channel.x
		//panelXAnimation.complete()
		//this.y = channel.y
		//panelYAnimation.complete()

		logoBg.color = channel.color
		channelInfoTitle.text = channel.text
		programsList.model.getEPGForChannel(channel.id);
		programsList.currentIndex = 0;

		//this.width = channel.width
		//panelWidthAnimation.complete()
		//this.height = channel.height
		selectedChannelLogo.source = channel.source
		//selectedChannelLogo.width = channel.width
		//selectedChannelLogo.height = channel.height
		programDescription.text = "";

		var w = this.parent.width / 3 * 2
		this.width = w
		this.height = this.parent.height - 50
		this.x = this.parent.x - this.parent.x + (this.parent.width - w) /  2 - 70
		this.y = this.parent.y - this.parent.y + 25
		this.updateProgress()
	}

	hide: {
		this.visible = false
	}

	updateProgress: {
		var channel = this.channel
		if (channel.program.startTime) {
			var currDate = new Date();
			var start = channel.program.startTime
			var stop = channel.program.stopTime
			currentProgress.progress = (currDate.getTime() - start.getTime()) / (stop.getTime() - start.getTime())
			currentProgramText.text = channel.program.start + "-" + channel.program.stop + " " + channel.program.title
		}
	}

	onBackPressed: {
		this.hide();
		this.rejected();
		return true;
	}

	Item {
		anchors.fill: parent;
		effects.shadow.spread: 5;
		effects.shadow.color: "#000a";
		effects.shadow.blur: 6;
	}

	Behavior on x { Animation { id: panelXAnimation; duration: 300; } }
	Behavior on y { Animation { id: panelYAnimation; duration: 300; } }
	Behavior on width { Animation { id: panelWidthAnimation; duration: 300; } }
}
