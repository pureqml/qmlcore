Activity {
	anchors.left: renderer.left;
	anchors.right: renderer.right;
	width: renderer.width;
	height: renderer.height;
	visible: active;

	MouseArea {
		anchors.fill: parent;
		hoverEnabled: true;
	}

	Rectangle {
		anchors.fill: parent;
		color: "#000";
		opacity: 0.5;
	}

	Rectangle {
		width: 200;
		height: 200;
		color: colorTheme.backgroundColor;
		anchors.centerIn: parent;
	}
}
