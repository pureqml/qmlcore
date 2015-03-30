MouseArea {
	property float value: 0;
	width: 30;
	height: 100;
	hoverEnabled: true;

	Rectangle {
		width: 5;
		height: parent.height;
		anchors.horizontalCenter: parent.horizontalCenter;
		color: colorTheme.backgroundColor;
	}

	Rectangle {
		y: parent.height * (1.0 - parent.value) - height / 2;
		height: 10;
		width: parent.width;
		anchors.horizontalCenter: parent.horizontalCenter;
		color: "#fff";
	}

	onMouseYChanged: {
		if (this.pressed)
			this.value = 1.0 - this.mouseY / this.height;
	}
}
