Rectangle {
	width: delegateText.paintedWidth + delegateIcon.paintedWidth + 30;
	height: 50;
	clip: true;
	color: activeFocus ? colorTheme.backgroundColor : "#0000";

	Text {
		id: delegateText;
		anchors.left: parent.left;
		anchors.right: delegateIcon.left;
		anchors.verticalCenter: parent.verticalCenter;
		anchors.leftMargin: 10;
		font.pointSize: 18;
		clip: true;
		text: model.text;
		color: parent.activeFocus ? colorTheme.focusedTextColor : colorTheme.textColor;
	}

	Image {
		id: delegateIcon;
		anchors.verticalCenter: parent.verticalCenter;
		anchors.right: parent.right;
		anchors.rightMargin: 10;
		source: model.source;
	}
}
