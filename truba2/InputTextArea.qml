Item {
	property string title;
	property string value: innerTextArea.text;
	width: innerTextArea.width;
	height: textAreaTitle.height + innerTextArea.height;

	Text {
		id: textAreaTitle;
		anchors.left: parent.left;
		text: parent.title;
		font.pointSize: 14;
		color: colorTheme.textColor;
	}

	TextArea {
		id: innerTextArea;
		width: 200;
		anchors.top: textAreaTitle.bottom;
		anchors.left: parent.left;
		visible: parent.visible;
	}
}
