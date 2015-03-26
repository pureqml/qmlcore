Item {
	id: threeDotsTextProto;
	property string text;
	property color color;
	property int pointSize;
	property bool reachedParentWidth: width < elipsisInnerText.paintedWidth;
	property bool cut: true;
	height: elipsisInnerText.paintedHeight;
	anchors.left: parent.left;
	anchors.right: parent.right;
	property color bgcolor: "#000";

	Rectangle {
		anchors.left: parent.left;
		anchors.bottom: parent.bottom;
		height: 24;
		width: elipsisInnerText.paintedWidth + 5;
		color: parent.bgcolor;
		z: !parent.cut ? 9 : 0;
	}

	Text {
		id: elipsisInnerText;
		anchors.fill: parent;
		horizontalAlignment: Text.AlignHCenter;
		color: threeDotsTextProto.color;
		text: threeDotsTextProto.text;
		font.pointSize: threeDotsTextProto.pointSize;
		z: !parent.cut ? 10 : 0;
	}

	onTextChanged: {
		if (this.cut)
			this.cutText();
		else 
			elipsisInnerText.text = this.text;
	}

	cutText: {
		elipsisInnerText.text = this.text;
		if (this.width < elipsisInnerText.paintedWidth) {
			var newLength = Math.round((this.width / elipsisInnerText.paintedWidth * elipsisInnerText.text.length)) - 2;
			var newValue = this.text.substring(0, newLength) + "...";
			elipsisInnerText.text = newValue;
		}
	}

	onCutChanged: {
		if (this.cut)
			this.cutText();
		else
			elipsisInnerText.text = this.text;
	}
}
