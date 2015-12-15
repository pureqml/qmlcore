Item {
	id: categoryDelegate;
	property string genre: model.text;
	width: parent.width;
	height: categoryLabel.paintedHeight + 10;
	clip: true;

	Rectangle {
		anchors.fill: parent;
		color: colorTheme.activeFocusColor;
		visible: parent.activeFocus;
	}

	MainText {
		id: categoryLabel;
		anchors.left: parent.left;
		anchors.leftMargin: 10;
		anchors.verticalCenter: parent.verticalCenter;
		text: categoryDelegate.genre;
		color: categoryDelegate.activeFocus ? colorTheme.focusedTextColor : colorTheme.activeTextColor;
		opacity: parent.activeFocus ? 1 : categoriesList.active ? 0.8 : 0.0;
	}
}
