Item {
	width: parent.width;
	height: epgStartProgramText.paintedHeight + 10;

	Rectangle {
		anchors.fill: parent;
		color: colorTheme.activeFocusColor;
		visible: parent.activeFocus;
	}

	MainText {
		id: epgStartProgramText;
		anchors.left: parent.left;
		anchors.verticalCenter: parent.verticalCenter;
		anchors.leftMargin: 5;
		color: parent.activeFocus ? colorTheme.focusedTextColor : colorTheme.textColor;
		text: model.start;
	}

	MainText {
		anchors.verticalCenter: parent.verticalCenter;
		anchors.left: epgStartProgramText.right;
		anchors.right: parent.right;
		anchors.leftMargin: 10;
		anchors.rightMargin: 5;
		color: parent.activeFocus ? colorTheme.focusedTextColor : colorTheme.textColor;
		text: model.title;
		clip: true;
	}
}
