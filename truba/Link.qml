MouseArea {
	property string text;
	width: buttonInnerText.paintedWidth + 20;
	height: buttonInnerText.paintedHeight + 10;
	hoverEnabled: true;

	Text {
		id: buttonInnerText;
		width: parent.width;
		anchors.verticalCenter: parent.verticalCenter;
		horizontalAlignment: Text.AlignHCenter;
		font.pointSize: 16;
		font.underline: true;
		color: colorTheme.textColor;
		text: parent.text;
	}
}
