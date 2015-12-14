Item {
	width: parent.width;
	height: 100;
	clip: true;

	Rectangle {
		anchors.fill: parent;
		color: colorTheme.activeFocusColor;
		visible: parent.activeFocus;
	}

	Image {
		id: menuItemIcon;
		anchors.left: parent.left;
		anchors.verticalCenter: parent.verticalCenter;
		anchors.leftMargin: 14;
		color: parent.activeFocus ? colorTheme.focusedTextColor : colorTheme.activeTextColor;
		source: colorTheme.res + (parent.activeFocus ? "b_" : "") + model.icon;
	}

	Text {
		id: innerMenuDelegateText;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.leftMargin: 100;
		anchors.verticalCenter: parent.verticalCenter;
		color: parent.activeFocus ? colorTheme.focusedTextColor : colorTheme.textColor;
		text: model.text;
		font.pixelSize: 28;
	}
}
