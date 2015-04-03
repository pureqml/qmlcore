BaseButton {
	width: delegateText.paintedWidth + delegateIcon.paintedWidth + 30;
	height: 50;
	clip: true;

	Text {
		id: delegateText;
		anchors.left: parent.left;
		anchors.right: delegateIcon.left;
		anchors.verticalCenter: parent.verticalCenter;
		anchors.leftMargin: 10;
		font.pointSize: 18;
		clip: true;
		text: model.text;
		color: colorTheme.focusedTextColor;
	}

	Image {
		id: delegateIcon;
		anchors.verticalCenter: parent.verticalCenter;
		anchors.right: parent.right;
		anchors.rightMargin: 10;
		source: model.source;
	}
}
