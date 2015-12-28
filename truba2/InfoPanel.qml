Activity {
	id: infoPanelProto;
	signal menuCalled;
	property variant channel;
	height: renderer.height / 5;
	anchors.left: parent.left;
	anchors.right: parent.right;
	anchors.bottom: parent.bottom;
	anchors.margins: 10;
	visible: active;
	focus: visible;
	name: "info";

	EPGModel { id: currentEpgModel; protocol: protocol; }

	Rectangle {
		id: currentChannelBg;
		height: parent.height;
		width: height;
		anchors.top: parent.top;
		anchors.left: parent.left;

		Image {
			id: currentChannelLogo;
			anchors.fill: parent;
			anchors.margins: 10;
			fillMode: Image.PreserveAspectFit;
		}
	}

	Rectangle {
		color: colorTheme.focusablePanelColor;
		anchors.top: parent.top;
		anchors.left: currentChannelBg.right;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		clip: true;

		MainText {
			id: currentChannelTitle;
			anchors.top: parent.top;
			anchors.left: parent.left;
			anchors.margins: 10;
			font.bold: true;
			color: colorTheme.accentTextColor;
		}

		MainText {
			id: currentProgramTitle;
			anchors.left: parent.left;
			anchors.top: currentChannelTitle.bottom;
			anchors.topMargin: 5;
			anchors.leftMargin: 10;
			anchors.rightMargin: 10;
			color: colorTheme.textColor;
		}

		Item {
			height: 5;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.top: currentProgramTitle.bottom;
			anchors.margins: 5;

			Rectangle {
				id: currentProgramProgress;
				property real progress;
				width: progress * parent.width;
				anchors.top: parent.top;
				anchors.left: parent.left;
				anchors.bottom: parent.bottom;
				color: colorTheme.accentColor;
			}
		}

		Item {
			id: descriptionClipper;
			anchors.top: currentProgramProgress.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.bottom: parent.bottom;
			anchors.margins: 5;
			clip: true;

			SmallText {
				id: currentProgramDescriptionText;
				//anchors.top: currentProgramProgress.bottom;
				//property int defaultY: descriptionClipper.y;
				//y: defaultY;
				anchors.top: parent.top;
				anchors.left: parent.left;
				anchors.right: parent.right;
				anchors.bottom: parent.bottom;
				color: colorTheme.textColor;
				wrap: true;

				Behavior on y { Animation { duration: 300; } }
			}
		}
	}

	BorderShadow { }

	Timer {
		id: updateTimer;
		interval: 10000;
		running: parent.visible;
		repeat: true;

		onTriggered: { infoPanelProto.updateProgress() }
	}

	WebButton {
		anchors.top: parent.top;
		anchors.right: parent.right;
		icon: "close.png";

		onClicked: { infoPanelProto.stop() }
	}

	WebButton {
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		icon: "menu.png";

		onClicked: { infoPanelProto.menuCalled() }
	}

	Timer {
		id: showInfoTimer;
		interval: 7000;

		onTriggered: {
			infoPanelProto.stop()
		}
	}

	updateProgress: {
		var program = this.channel.program;
		if (!program || !program.start)
			return

		currentProgramTitle.text = program.start + (program.start ? " - " : "") + program.stop + " " + program.title;
		currentProgramDescriptionText.text = program.description

		var currDate = new Date();
		var start = program.startTime
		var stop = program.stopTime
		var progress = (currDate.getTime() - start.getTime()) / (stop.getTime() - start.getTime())
		currentProgramProgress.progress = progress
		if (progress >= 1.0)
			this.channel.program = currentEpgModel.getCurrentProgram(this.channel.id)
	}

	onUpPressed: {
		showInfoTimer.restart()
		//if (!this.visible || !this.channel.program || !this.channel.program.description)
			//return

		//currentProgramDescriptionText.y -= 20;
	}

	onDownPressed: {
		showInfoTimer.restart()
		//if (!this.visible || !this.channel.program || !this.channel.program.description)
			//return

		//currentProgramDescriptionText.y += 20;
	}

	onActiveChanged: {
		if (this.active)
			showInfoTimer.restart()
		else
			showInfoTimer.stop()
	}

	show(channel): {
		if (!channel) {
			log("channel is null")
			return
		}

		this.start()
		this.channel = channel
		currentProgramDescriptionText.y = currentProgramDescriptionText.defaultY

		currentChannelBg.color = channel.color
		currentChannelTitle.text = channel.text
		currentChannelLogo.source = channel.source
		this.updateProgress()
	}
}
