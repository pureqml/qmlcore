Item {
	id: threeDotsTextProto;
	property string text;
	property color color;
	height: threeDotsInnerText.paintedHeight;
	anchors.left: parent.left;
	anchors.right: parent.right;

	Text {
		id: threeDotsInnerText;
		anchors.fill: parent;
		color: threeDotsTextProto.color;
		text: threeDotsTextProto.text;
	}

	onTextChanged: {
		threeDotsInnerText.text = this.text;
		if (this.width < threeDotsInnerText.paintedWidth) {
			var newLength = Math.round((this.width / threeDotsInnerText.paintedWidth * threeDotsInnerText.text.length)) - 2;
			var newValue = this.text.substring(0, newLength) + "...";
			threeDotsInnerText.text = newValue;
		}
	}
}
