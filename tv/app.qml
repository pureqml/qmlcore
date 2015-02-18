Item {
	id: mainWindow;
	anchors.fill: renderer;
	anchors.leftMargin: 75;
	anchors.rightMargin: 75;
	anchors.bottomMargin: 40;
	anchors.topMargin: 40;

	DomButton {
		id: db1;
		anchors.bottom: parent.bottom;
		anchors.left: parent.left;
		height: parent.height / 9;
		width: parent.width / 8;
		text: "15:20";
	}

	DomButton {
		id: db2;
		anchors.bottom: parent.bottom;
		anchors.left: db1.right;
		anchors.leftMargin: parent.width / 100;
		height: parent.height / 9;
		width: parent.width / 8;
		text: "015 Россия HD";
	}

	DomButton {
		id: db3;
		anchors.bottom: parent.bottom;
		anchors.left: db2.right;
		anchors.right: db4.left;
		anchors.leftMargin: parent.width / 100;
		anchors.rightMargin: parent.width / 100;
		height: activeFocus ? 200 : 76;//db1.height;
		text: "No targets specified and no makefile found.";
	}

	DomButton {
		id: db4;
		anchors.bottom: parent.bottom;
		anchors.right: db5.left;
		anchors.rightMargin: parent.width / 100;
		height: parent.height / 9;
		width: parent.width / 16;
		text: "Options";
	}

	DomButton {
		id: db5;
		anchors.bottom: parent.bottom;
		anchors.right: parent.right;
		anchors.rightMargin: parent.width / 12;
		height: parent.height / 9;
		width: parent.width / 16;
		text: "EXIT";
	}
}
