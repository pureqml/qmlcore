FocusablePanel {
	width: 240;
	height: 90;

	property string source: "res/pipeline.png";
	property string text: "TRUBA\.TV";

	Image {
		anchors.verticalCenter: parent.verticalCenter;
		anchors.left: parent.left;
		anchors.leftMargin: 8;
		source: parent.source;
	}

	Text {
		anchors.verticalCenter: parent.verticalCenter;
		anchors.right: parent.right;
		anchors.rightMargin: 16;
		text: parent.text;
		font.pointSize: 20;
		color: "white";
	}
}