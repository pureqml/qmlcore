Item {
	id: providerDelegate;
	width: parent.width;
	height: categoryLabel.paintedHeight + 10;
	clip: true;

	Rectangle {
		anchors.fill: parent;
		color: colorTheme.activeFocusColor;
		visible: parent.activeFocus;
	}

	Image {
		id: providerChecked;
		anchors.left: parent.left;
		anchors.leftMargin: 10;
		anchors.verticalCenter: parent.verticalCenter;
		source: colorTheme.res + (parent.activeFocus ? "b_" : "") + (model.selected ? "" : "un") + "checked.png";
	}

	MainText {
		id: categoryLabel;
		anchors.left: providerChecked.right;
		anchors.leftMargin: 10;
		anchors.verticalCenter: parent.verticalCenter;
		text: model.text;
		color: parent.activeFocus ? colorTheme.focusedTextColor : colorTheme.activeTextColor;
		opacity: parent.activeFocus ? 1 : categoriesList.active ? 0.8 : 0.0;
	}

	Image {
		anchors.right: parent.right;
		anchors.verticalCenter: parent.verticalCenter;
		source: model.source;
	}
}
