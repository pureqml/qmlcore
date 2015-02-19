ListView {
	width: parent.width;
	height: parent.height;
	anchors.left: parent.left;
	anchors.bottom: parent.bottom;
	spacing: 20;
	orientation: 1;

	delegate: Item {
		id: contextItemProto;
		height: 20;
		width: height + contextText.width + 10;

		Rectangle {
			id: contextColorRectangle;
			height: parent.height;
			width: height;
			anchors.left: parent.left;
			anchors.verticalCenter: parent.verticalCenter;
			color: model.color;
			radius: height / 4;
			border.width: 2;
			border.color: "#fff";
		}

		Text {
			id: contextText;
			anchors.left: contextColorRectangle.right;
			anchors.verticalCenter: parent.verticalCenter;
			anchors.leftMargin: 8;
			color: "#fff";
			text: model.text;
		}
	} 
}

