Item {
	width: parent.cellWidth;
	height: parent.cellHeight;

	Rectangle {
		id: channelDelegateBacground;
		anchors.fill: parent;
		anchors.margins: 20;
		radius: height / 8;
		color: model.color;
	}

	Image {
		anchors.centerIn: channelDelegateBacground;
		source: model.source;
	}
}
