Rectangle {
	width: 200; height: 200;
	Column {
		anchors.fill: parent;
		anchors.margins: 20;
		spacing: 20;
		TextEdit { width: parent.width; height: 30; }
		TextEdit { width: parent.width; height: 30; }
		Button { text: "Login"; anchors.horizontalCenter: parent.horizontalCenter; }
	}
}
