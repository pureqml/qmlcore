MouseArea {
	property float value: 0;
	width: 30;
	height: 120;
	hoverEnabled: true;

	Rectangle {
		id: volumeBg;
		width: 5;
		height: parent.height;
		anchors.horizontalCenter: parent.horizontalCenter;
		color: colorTheme.activeBackgroundColor;
		opacity: 0.7;
	}

	Rectangle {
		height: parent.height - volumeCursor.y;
		anchors.bottom: volumeBg.bottom;
		anchors.left: volumeBg.left;
		anchors.right: volumeBg.right;
		color: "#f00";
	}

	Rectangle {
		id: volumeCursor;
		y: parent.height * (1.0 - parent.value) - height / 2;
		height: 10;
		width: 30;
		anchors.horizontalCenter: parent.horizontalCenter;
		color: colorTheme.activeBackgroundColor;
	}

	updatePosition:	{ this.value = 1.0 - this.mouseY / this.height; }
	onClicked:		{ this.updatePosition(); }

	onMouseYChanged: {
		if (this.pressed)
			this.updatePosition();
	}
}
