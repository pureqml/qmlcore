MouseArea {
	property string text;
	width: buttonInnerText.paintedWidth + 20;
	height: buttonInnerText.paintedHeight + 10;
	hoverEnabled: true;

	Rectangle {
		anchors.fill: parent;
		color: colorTheme.activeDialogBackground;

		Text {
			id: buttonInnerText;
			width: parent.width;
			anchors.verticalCenter: parent.verticalCenter;
			horizontalAlignment: Text.AlignHCenter;
			font.pointSize: 16;
			color: colorTheme.focusedTextColor;
			text: parent.parent.text;
		}
	}
}
