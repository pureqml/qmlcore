ListView {
	id: options;
	//TODO: use contentWidth instead!
	width: 200;
	height: parent.height;
	anchors.right: parent.right;
	anchors.bottom: parent.bottom;
	orientation: 1;
	spacing: 10;
	model: optionsModel;
	delegate: Item {
		width: icon.width + optionText.paintedWidth + 10;
		height: parent.height;

		Image {
			id: icon;
			source: model.source;
			anchors.left: parent.left;
			anchors.verticalCenter: parent.verticalCenter;
		}

		Text {
			id: optionText;
			anchors.left: icon.right;
			anchors.leftMargin: 10;
			anchors.verticalCenter: parent.verticalCenter;
			color: "#fff";
			text: model.text;
		}
	}
}
