Item {
	id: mainWindow;
	anchors.fill: renderer;
	anchors.leftMargin: 75;
	anchors.rightMargin: 75;
	anchors.bottomMargin: 40;
	anchors.topMargin: 40;

	GreenButton {
		id: db1;
		anchors.bottom: parent.bottom;
		anchors.left: parent.left;
		height: parent.height / 9;
		width: parent.width / 8;
		text: "15:20";

		onRightPressed: { db2.forceActiveFocus(); }
	}

	GreenButton {
		id: db2;
		anchors.bottom: parent.bottom;
		anchors.left: db1.right;
		anchors.leftMargin: parent.width / 100;
		height: parent.height / 9;
		width: parent.width / 8;
		text: "015 Россия HD";

		onRightPressed: { db3.forceActiveFocus(); }
		onLeftPressed: { db1.forceActiveFocus(); }
	}

	GreenButton {
		id: db3;
		anchors.bottom: parent.bottom;
		anchors.left: db2.right;
		anchors.right: db4.left;
		anchors.leftMargin: parent.width / 100;
		anchors.rightMargin: parent.width / 100;
		height: activeFocus ? 200 : db1.height;
	
		Text {
			anchors.fill: parent;
			anchors.margins: 10;
			text: "No targets specified and no makefile found.";
			font.pointSize: 40;
			color: "white";
			wrap: true;
		}

		onRightPressed: { db4.forceActiveFocus(); }
		onLeftPressed: { db2.forceActiveFocus(); }
	}

	Column {
		id: options;
		spacing: 10;
		anchors.bottom: parent.bottom;
		anchors.right: db5.left;
		anchors.rightMargin: parent.width / 100;
		width: parent.width / 16;
		property bool show;
		handleNavigationKeys: true;

		Behavior on opacity	{ Animation { duration: 500; } }

		GreenButton {
			height: mainWindow.height / 9;
			width: parent.width;
			text: "TTX";
			opacity: options.show ? 1 : 0;
		}
		
		GreenButton {
			height: mainWindow.height / 9;
			width: parent.width;
			text: "Sub";
			opacity: options.show ? 1 : 0;
		}
		
		GreenButton {
			height: mainWindow.height / 9;
			width: parent.width;
			text: "Audio";
			opacity: options.show ? 1 : 0;
		}

		GreenButton {
			id: db4;
			height: mainWindow.height / 9;
			width: parent.width;// / 16;
			text: "Options";
			color: activeFocus || options.show ? "#539d00" : "black";

			onTriggered: { options.show = !options.show; }
		}

		onRightPressed: { db5.forceActiveFocus(); }
		onLeftPressed: { db3.forceActiveFocus(); }
	}

	Button {
		id: db5;
		anchors.bottom: parent.bottom;
		anchors.right: parent.right;
		height: parent.height / 9;
		width: parent.width / 16;
		text: "EXIT";

		onLeftPressed: { db4.forceActiveFocus(); }
	}

	Protocol {
		id: protocol;
		clientId: "er_ottweb_device";
		deviceId: "123";
		ssoSystem: "er";
	}
}
