BaseButton {
	width: 260;
	height: 100;

	property string source;
	property string text;

	Image {
		id: buttonImage;
		anchors.verticalCenter: parent.verticalCenter;
		anchors.left: parent.left;
		anchors.leftMargin: 8;
		source: parent.source;
	}

	Text {
		anchors.verticalCenter: parent.verticalCenter;
		anchors.right: parent.right;
		anchors.left: buttonImage.right;
		horizontalAlignment: Text.AlignHCenter;
		text: parent.text;
		font.pointSize: 20;
		color: "white";
		wrap: true;
	}
}