Item {
	property string title;
	property string value: innerTextInput.text;
	width: innerTextInput.width;
	height: inputTitle.height + innerTextInput.height;

	Text {
		id: inputTitle;
		anchors.left: parent.left;
		text: parent.title;
		font.pointSize: 14;
		color: colorTheme.textColor;
	}

	TextInput {
		id: innerTextInput;
		anchors.top: inputTitle.bottom;
		anchors.left: parent.left;
		visible: parent.visible;
	}
}
