Rectangle {
	width: parent.width;
	color: activeFocus ? colorTheme.activeBackgroundColor : colorTheme.backgroundColor;
	height: 50;
	clip: true;

	Text {
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

	Behavior on color { Animation { duration: 300; } }
}
