Item {
	property int spacing: parent.height / 8 - 5;
	width: parent.cellWidth;
	height: parent.cellHeight;

	Rectangle {
		id: channelDelegateBacground;
		anchors.fill: parent;
		anchors.margins: parent.height / 8;
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
		//TODO: remove this, when PreserveAspectFit fill mode will implemented.
		height: paintedHeight >= parent.height - parent.spacing ? parent.height - parent.spacing : paintedHeight;
		width: paintedWidth * (height / paintedHeight);
		anchors.centerIn: channelDelegateBacground;
		source: model.source;
	}
}
