Item {
	id: threeDotsTextProto;
	property string text;
	property color color;
	height: elipsisInnerText.paintedHeight;
	anchors.left: parent.left;
	anchors.right: parent.right;

	Text {
		id: elipsisInnerText;
		anchors.fill: parent;
		color: threeDotsTextProto.color;
		text: threeDotsTextProto.text;
	}

	onTextChanged: {
		elipsisInnerText.text = this.text;
		if (this.width < elipsisInnerText.paintedWidth) {
			var newLength = Math.round((this.width / elipsisInnerText.paintedWidth * elipsisInnerText.text.length)) - 2;
			var newValue = this.text.substring(0, newLength) + "...";
			elipsisInnerText.text = newValue;
		}
	}
}
