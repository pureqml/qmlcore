Item {
	height: logo.height;
	anchors.top: renderer.top;
	anchors.left: renderer.left;
	anchors.leftMargin: 75;
	anchors.topMargin: 42;

	Image {
		id: logo;
		anchors.top: parent.top;
		anchors.left: parent.left;
		source: "res/logoDomru.png";
	}

	CurrentTimeText {
		anchors.top: logo.top;
		anchors.left: logo.right;
		anchors.leftMargin: 10;
		color: "white";
		font.pointSize: 16;
	}

	CurrentDateText {
		anchors.bottom: logo.bottom;
		anchors.left: logo.right;
		anchors.leftMargin: 10;
		color: "#ccc";
	}
}
