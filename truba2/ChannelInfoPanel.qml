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
		anchors.margins: -1000;
		color: logoBg.color;
		opacity: parent.visible ? 1.0 : 0.0;
		effects.brightness: 0.4;

		Behavior on opacity { Animation { duration: 300; } }
	}

	MouseArea {
		anchors.fill: fog;
		hoverEnabled: true;

		onClicked: { channelInfoPanelProto.reject() }
	}

	Rectangle {
		anchors.fill: parent;
		color: colorTheme.activePanelColor;
	}

	Rectangle {
		id: logoBg;
		anchors.top: parent.top;
		anchors.left: parent.left;
	}

	Image {
		id: selectedChannelLogo;
		anchors.fill: logoBg;
		anchors.margins: 10;
		fillMode: Image.PreserveAspectFit;
	}

	Text {
		id: channelInfoTitle;
		anchors.top: parent.top;
		anchors.left: logoBg.right;
		anchors.right: parent.right;
		anchors.margins: 10;
		color: colorTheme.accentTextColor;
		clip: true;
		font.pixelSize: 28;
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
		color: colorTheme.activeTextColor;
		wrap: true;

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

		panelXAnimation.disable()
		this.x = channel.x
		panelYAnimation.disable()
		this.y = channel.y

		logoBg.color = channel.color
		channelInfoTitle.text = channel.text
		programsList.model.getEPGForChannel(channel.id);
		programsList.currentIndex = 0;

		panelWidthAnimation.disable()
		this.width = channel.width
		this.height = channel.height
		selectedChannelLogo.source = channel.source
		logoBg.width = channel.width
		logoBg.height = channel.height
		programDescription.text = "";

		panelWidthAnimation.enable()
		var w = this.parent.width / 3 * 2
		this.width = w
		this.height = this.parent.height - 50
		panelXAnimation.enable()
		this.x = this.parent.x - this.parent.x + (this.parent.width - w) /  2 - 70
		panelYAnimation.enable()
		this.y = this.parent.y - this.parent.y + 25
		this.updateProgress()
	}

	hide: {
		this.visible = false
	}

	reject: {
		this.hide();
		this.rejected();
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
		this.reject();
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
