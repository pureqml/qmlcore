MouseArea {
	width: parent.cellWidth;
	height: parent.cellHeight;
	hoverEnabled: true;

	Rectangle {
		id: channelIconBackground;
		anchors.left: parent.left;
		anchors.top: parent.top;
		height: channelIcon.maxWidth;
		width: channelIcon.maxWidth;
		color: model.color;
	}

	Image {
		id: channelIcon;
		property int maxWidth: 50;
		width: paintedWidth >= maxWidth ? maxWidth : paintedWidth;
		height: paintedHeight * (width / paintedWidth);
		anchors.centerIn: channelIconBackground;
		source: model.source;
	}

	Text {
		id: channelDelegateTitle;
		anchors.left: channelIconBackground.right;
		anchors.right: parent.right;
		anchors.top: channelIconBackground.top;
		anchors.topMargin: (channelIconBackground.height - paintedHeight) / 2;
		anchors.leftMargin: 10;
		color: colorTheme.textColor;
		text: model.text;
		wrap: true;
		font.bold: true;

		onCompleted: { this._updateSize(); }	//TODO: Crunch for explicitly calculating text size after word wrapping.
	}

	Image {
		id: detailsIcon;
		anchors.verticalCenter: startProgramText.verticalCenter;
		anchors.right: parent.right;
		source: "res/details.png";
		visible: startProgramText.text != "" && parent.containsMouse;
		opacity: parent.activeFocus ? 1.0 : 0.5;

		Behavior on opacity { Animation { duration: 300; } }
	}

	Text {
		id: startProgramText;
		anchors.left: parent.left;
		anchors.top: channelIconBackground.bottom;
		anchors.margins: 5;
		color: colorTheme.textColor;
		text: model.program.start;
		font.pointSize: 12;
		font.bold: true;
	}

	Text {
		anchors.left: startProgramText.right;
		anchors.right: detailsIcon.left;
		anchors.top: channelIconBackground.bottom;
		anchors.leftMargin: 5;
		anchors.rightMargin: -10;
		anchors.topMargin: 5;
		color: colorTheme.textColor;
		text: model.program.title;
		font.pointSize: 12;
		clip: true;
	}

	onMouseXChanged: { this.lockParent(); }
	onMouseYChanged: { this.lockParent(); }

	lockParent: {
		if (!detailsIcon.visible)
			return;

		var x = this.mouseX;
		var y = this.mouseY;
		this.parent.hoverEnabled = !(this.mouseX <= detailsIcon.x + detailsIcon.width &&
			this.mouseY >= channelIconBackground.y + channelIconBackground.height && this.mouseY <= startProgramText.y + startProgramText.height);
	}

	onContainsMouseChanged: {
		if (!this.containsMouse)
			this.parent.mouseLeaved = true;
	}

	onClicked: {
		var x = this.mouseX;
		var y = this.mouseY;
		if (this.mouseX <= detailsIcon.x + detailsIcon.width &&
			this.mouseY >= channelIconBackground.y + channelIconBackground.height && this.mouseY <= startProgramText.y + startProgramText.height)
			this.parent.detailsRequest();
	}
}
