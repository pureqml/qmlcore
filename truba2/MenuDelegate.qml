Item {
	width: 100 > innerMenuDelegateText.width ? 120 : innerMenuDelegateText.width + 20;
	height: parent.height;

	Rectangle {
		anchors.fill: parent;
		color: colorTheme.activeFocusColor;
		visible: parent.activeFocus;
	}

	Image {
		id: menuItemIcon;
		anchors.bottom: innerMenuDelegateText.top;
		anchors.horizontalCenter: parent.horizontalCenter;
		anchors.bottomMargin: 10;
		color: parent.activeFocus ? colorTheme.focusedTextColor : colorTheme.activeTextColor;
		source: model.icon;
	}

	Text {
		id: innerMenuDelegateText;
		anchors.bottom: parent.bottom;
		anchors.bottomMargin: 10;
		anchors.horizontalCenter: menuItemIcon.horizontalCenter;
		horizontalAlignment: Text.AlignHCenter;
		color: parent.activeFocus ? colorTheme.focusedTextColor : colorTheme.textColor;
		text: model.text;
		font.pixelSize: 28;
	}
}
