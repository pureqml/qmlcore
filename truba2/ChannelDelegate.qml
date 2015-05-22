MouseArea {
	width: parent.cellWidth;
	height: parent.cellHeight;
	hoverEnabled: true;

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

	Image {
		id: detailsIcon;
		anchors.verticalCenter: startProgramText.verticalCenter;
		anchors.right: parent.right;
		anchors.rightMargin: 10;
		source: "res/details.png";
		visible: startProgramText.text != "";
		opacity: parent.activeFocus ? 1.0 : 0.5;

		Behavior on opacity { Animation { duration: 300; } }
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
		anchors.right: detailsIcon.left;
		anchors.top: channelIcon.bottom;
		anchors.margins: 5;
		color: colorTheme.textColor;
		text: model.programName;
		font.pointSize: 12;
		clip: true;
	}

	onClicked: {
		var x = this.mouseX;
		var y = this.mouseY;
		if (this.mouseX >= detailsIcon.x && this.mouseX <= detailsIcon.x + detailsIcon.width &&
			this.mouseY >= detailsIcon.y && this.mouseY <= detailsIcon.y + detailsIcon.height)
			this.parent.detailsRequest();
	}
}
