Item {
	width: menuItemIcon.paintedWidth > innerMenuDelegateText.paintedWidth ? menuItemIcon.paintedWidth + 20 : innerMenuDelegateText.paintedWidth + 20;
	height: parent.height;

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
		color: parent.activeFocus ? colorTheme.focusedTextColor : colorTheme.textColor;
		text: model.text;
		font.pixelSize: 18;
	}
}
