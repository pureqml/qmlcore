Item {
	width: parent.cellWidth;
	height: parent.cellHeight;

	Rectangle {
		id: channelIconBackground;
		anchors.left: parent.left;
		anchors.top: parent.top;
		height: channelIcon.maxHeight;
		width: channelIcon.maxHeight;
		color: model.color;
	}

	Image {
		id: channelIcon;
		property int maxHeight: 50;
		//TODO: remove this, when PreserveAspectFit fill mode will implemented.
		height: paintedHeight >= maxHeight ? maxHeight : paintedHeight;
		width: paintedWidth * (height / paintedHeight);
		anchors.centerIn: channelIconBackground;
		source: model.source;
	}

	Text {
		id: channelDelegateTitle;
		anchors.left: channelIconBackground.right;
		anchors.right: parent.right;
		anchors.top: channelIcon.top;
		anchors.topMargin: (channelIcon.height - paintedHeight) / 2;
		anchors.leftMargin: 10;
		color: colorTheme.textColor;
		text: model.text;
		wrap: true;
		font.bold: true;
	}

	Text {
		id: startProgramText;
		anchors.left: parent.left;
		anchors.top: channelIcon.bottom;
		anchors.margins: 5;
		color: colorTheme.textColor;
		text: model.start;
		font.pointSize: 12;
		font.bold: true;
	}

	Text {
		anchors.left: startProgramText.right;
		anchors.right: parent.right;
		anchors.top: channelIcon.bottom;
		anchors.margins: 5;
		color: colorTheme.textColor;
		text: model.programName;
		font.pointSize: 12;
	}
}
