Rectangle {
	id: channelDelegateProto;
	property bool toggled: false;
	width: parent.width;
	height: channelLabelText.paintedHeight * 3.5;
	color: colorTheme.focusablePanelColor;
	clip: true;

	Rectangle {
		anchors.fill: parent;
		color: channelDelegateProto.toggled ? colorTheme.accentColor : colorTheme.activeFocusColor;
		visible: parent.activeFocus;

		Behavior on color { ColorAnimation { duration: 300; } }
	}

	Rectangle {
		id: logoBg;
		width: height;
		color: model.color;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.bottom: parent.bottom;
		clip: true;

		Rectangle {
			color: "#0000";
			anchors.fill: parent;
			anchors.topMargin: 4;
			anchors.leftMargin: 4;
			anchors.bottomMargin: 4;
			border.width: 4;
			border.color: colorTheme.activeFocusColor;
			visible: channelDelegateProto.activeFocus;
		}

		SmallText {
			anchors.verticalCenter: parent.verticalCenter;
			anchors.left: parent.left;
			anchors.leftMargin: paintedWidth > logoBg.width - 10 ? 5 : (logoBg.width - paintedWidth) / 2;
			text: model.text;
			color: colorTheme.focusedTextColor;
			visible: channelLogo.status != Image.Ready;
		}

		Image {
			id: channelLogo;
			anchors.fill: parent;
			anchors.margins: 10;
			fillMode: Image.PreserveAspectFit;
			source: model.source;
		}
	}

	MainText {
		id: channelLabelText;
		anchors.top: parent.top;
		anchors.left: logoBg.right;
		anchors.right: parent.right;
		anchors.margins: 10;
		text: model.lcn + ". " + model.text;
		color: parent.activeFocus ? colorTheme.focusedTextColor : colorTheme.accentTextColor;
		font.bold: true;
	}

	Item {
		anchors.top: channelLabelText.bottom;
		anchors.left: logoBg.right;
		anchors.right: parent.right;
		anchors.bottom: durationText.top;
		anchors.leftMargin: 10;
		anchors.rightMargin: 10;

		SmallText {
			anchors.verticalCenter: parent.verticalCenter;
			anchors.left: parent.left;
			anchors.right: parent.right;
			text: model.program.title;
			color: channelDelegateProto.activeFocus ? colorTheme.focusedTextColor : colorTheme.textColor;
		}
	}

	SmallText {
		id: durationText;
		anchors.left: logoBg.right;
		anchors.bottom: parent.bottom;
		anchors.margins: 10;
		text: model.program.start + (model.program.start ? " - " : "") + model.program.stop;
		color: channelDelegateProto.activeFocus ? colorTheme.focusedTextColor : colorTheme.textColor;
	}

	Item {
		height: 3;
		anchors.left: durationText.right;
		anchors.right: parent.right;
		anchors.verticalCenter: durationText.verticalCenter;
		anchors.leftMargin: 10;
		anchors.rightMargin: 10;

		Rectangle {
			id: programProgress;
			width: model.program.progress * parent.width;
			anchors.top: parent.top;
			anchors.left: parent.left;
			anchors.bottom: parent.bottom;
			color: colorTheme.accentColor;
		}
	}

	Timer {
		id: toggleTimer;
		interval: 300;
		repeat: false;

		onTriggered: { channelDelegateProto.toggled = false }
	}

	onSelectPressed: {
		this.toggled = true
		toggleTimer.restart()
		event.accepted = false
	}

	Behavior on opacity { Animation { duration: 300; } }
}
