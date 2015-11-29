Item {
	id: categoryDelegate;
	property string genre: model.text;
	width: parent.width;
	opacity: activeFocus ? 1 : 0.8;
	height: 100;
	clip: true;

	AlphaControl { alphaFunc: MaxAlpha; }

	Text {
		anchors.centerIn: parent;
		text: categoryDelegate.genre;
		color: categoryDelegate.activeFocus ? colorTheme.focusedTextColor : colorTheme.activeTextColor;
		visible: contentView.showFocused;
		font.pixelSize: 18;
	}
}
