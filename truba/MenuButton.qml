FocusablePanel {
	width: 240;
	height: 90;

	Image {
		anchors.verticalCenter: parent.verticalCenter;
		anchors.left: parent.left;
		anchors.leftMargin: 8;
		source: "res/pipeline.png";
	}

	Text {
		anchors.verticalCenter: parent.verticalCenter;
		anchors.right: parent.right;
		anchors.rightMargin: 16;
		text: "TRUBA\.TV";
		font.pointSize: 20;
		color: "white";
	}
}