Rectangle {
	id: inputProto;
	property string text;
	color: "#fff";
	border.color: "#00f";
	border.width: 1;

	TextEdit {
		id: innerEditText;
		anchors.fill: parent;
		anchors.margins: parent.border.width;
		text: inputProto.text;
	}

	removeChar: { inputProto.text = inputProto.text.slice(0, inputProto.text.length - 1); }
}
