BaseButton {
	width: innerText.width * 2;
	height: 60;

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
		id: innerText;
		anchors.verticalCenter: parent.verticalCenter;
		anchors.left: buttonImage.right;
		anchors.leftMargin: 8;
		text: parent.text;
		font.pointSize: 18;
		color: "white";
		wrap: true;
	}
}