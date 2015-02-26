Rectangle {
	id: inputProto;
	property string text;
	property bool passwordMode: false;
	color: "#fff";
	border.color: "#00f";
	border.width: 1;

	TextEdit {
		id: innerEditText;
		anchors.fill: parent;
		anchors.margins: parent.border.width;
	}

	onTextChanged: {
		if (inputProto.passwordMode) {
			innerEditText.text = "";
			for (var i in inputProto.text)
				innerEditText.text += "*";
		} else {
			innerEditText.text = inputProto.text;
		}
	}

	removeChar: { inputProto.text = inputProto.text.slice(0, inputProto.text.length - 1); }
}
