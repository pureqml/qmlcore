FocusablePanel {
	width: 240;
	height: 90;
	clip: true;

	property string source;
	property string text;

	signal triggered;

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

	onSelectPressed: { this.triggered(); }
	onClicked: { this.triggered(); }
}