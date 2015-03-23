BaseButton {
	id: inputProto;
	property string text;
	property bool passwordMode: false;

	TextEdit {
		id: innerEditText;
		anchors.fill: parent;
		anchors.rightMargin: 5;
		anchors.leftMargin: 5;
		activeFocus: parent.activeFocus;
		color: "#fff";
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
