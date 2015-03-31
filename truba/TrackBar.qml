MouseArea {
	property float value: 0;
	width: 30;
	height: 100;
	hoverEnabled: true;

	Rectangle {
		id: volumeBg;
		width: 5;
		height: parent.height;
		anchors.horizontalCenter: parent.horizontalCenter;
		color: colorTheme.backgroundColor;
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
		width: parent.width;
		anchors.horizontalCenter: parent.horizontalCenter;
		color: "#fff";
	}

	updatePosition:	{ this.value = 1.0 - this.mouseY / this.height; }
	onClicked:		{ this.updatePosition(); }

	onMouseYChanged: {
		if (this.pressed)
			this.updatePosition();
	}
}
