Item {
	id: domLogo;
	anchors.top: parent.top;
	anchors.left: parent.left;
	width: 200;
	height: 60;

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