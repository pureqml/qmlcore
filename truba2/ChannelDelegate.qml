Rectangle {
	id: channelDelegateProto;
	width: parent.width;
	height: 100;
	color: colorTheme.focusablePanelColor;
	clip: true;

	Rectangle {
		anchors.fill: parent;
		color: colorTheme.activeFocusColor;
		visible: parent.activeFocus;
	}

	Rectangle {
		id: logoBg;
		width: height;
		color: model.color;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.bottom: parent.bottom;

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

		Image {
			anchors.fill: parent;
			anchors.margins: 10;
			fillMode: Image.PreserveAspectFit;
			source: model.source;
		}
	}

	Text {
		anchors.top: parent.top;
		anchors.left: logoBg.right;
		anchors.right: parent.right;
		anchors.margins: 10;
		text: model.text;
		color: parent.activeFocus ? colorTheme.focusedTextColor : colorTheme.accentTextColor;
		font.pixelSize: 21;
		font.bold: true;
	}

	Text {
		anchors.left: logoBg.right;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		anchors.leftMargin: 10;
		anchors.rightMargin: 10;
		anchors.bottomMargin: 20;
		text: model.program.start + (model.program.start ? "-" : "") + model.program.stop + " " + model.program.title;
		color: parent.activeFocus ? colorTheme.focusedTextColor : colorTheme.textColor;
		font.pixelSize: 18;
	}

	Item {
		height: 3;
		anchors.left: logoBg.right;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		anchors.leftMargin: 10;
		anchors.rightMargin: 10;
		anchors.bottomMargin: 10;

		Rectangle {
			id: programProgress;
			width: model.program.progress * parent.width;
			anchors.top: parent.top;
			anchors.left: parent.left;
			anchors.bottom: parent.bottom;
			color: colorTheme.accentColor;
		}
	}
}
