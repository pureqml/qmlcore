Item {
	width: parent.cellWidth;
	height: parent.cellHeight;

	Rectangle {
		id: channelDelegateBacground;
		anchors.fill: parent;
		anchors.margins: 20;
		radius: height / 8;
		color: model.color;
		clip: true;

		Text {
			anchors.centerIn: parent;
			color: "#000";
			text: model.text;
			font.pointSize: 18;
			visible: channelDelegateIcon.source == "";
		}
	}

	Image {
		id: channelDelegateIcon;
		anchors.centerIn: channelDelegateBacground;
		source: model.source;
	}
}
