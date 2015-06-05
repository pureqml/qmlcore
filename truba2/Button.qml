MouseArea {
	property string text;
	width: innerText.paintedWidth + 20;
	height: innerText.paintedHeight + 10;
	hoverEnabled: true;

	Rectangle {
		anchors.fill: parent;
		color: colorTheme.activeDialogBackground;
	}

	Text {
		id: innerText;
		width: parent.width;
		height: parent.height;
		verticalAlignment: Text.AlignVCenter;
		horizontalAlignment: Text.AlignHCenter;
		text: parent.text;
		color: colorTheme.focusedTextColor;
		font.pointSize: 20;
	}
}
