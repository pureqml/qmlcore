Item {
	width: parent.width;
	height: 40;

	Text {
		id: epgStartProgramText;
		anchors.left: parent.left;
		anchors.verticalCenter: parent.verticalCenter;
		anchors.leftMargin: 5;
		color: parent.activeFocus ? colorTheme.focusedTextColor : colorTheme.textColor;
		text: model.start;
	}

	Text {
		anchors.verticalCenter: parent.verticalCenter;
		anchors.left: epgStartProgramText.right;
		anchors.right: parent.right;
		anchors.leftMargin: 10;
		anchors.rightMargin: 5;
		color: parent.activeFocus ? colorTheme.focusedTextColor : colorTheme.textColor;
		text: model.title;
		clip: true;
		font.pixelSize: 14;
	}
}
