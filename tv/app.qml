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

	GreenButton {
		id: db4;
		anchors.bottom: parent.bottom;
		anchors.right: db5.left;
		anchors.rightMargin: parent.width / 100;
		height: parent.height / 9;
		width: parent.width / 16;
		text: "Options";
	    color: activeFocus || options.show ? "#539d00" : "black";

		onRightPressed: { db5.forceActiveFocus(); }
		onLeftPressed: { db3.forceActiveFocus(); }
		onUpPressed: {
			if (options.show)
				options.forceActiveFocus();
		}

		onTriggered: {
			options.show = !options.show;
		}
	}

	Button {
		id: db5;
		anchors.bottom: parent.bottom;
		anchors.right: parent.right;
		anchors.rightMargin: parent.width / 12;
		height: parent.height / 9;
		width: parent.width / 16;
		text: "EXIT";

		onLeftPressed: { db4.forceActiveFocus(); }
	}

	Column {
		id: options;
		spacing: 10;
		anchors.bottom: db4.top;
		anchors.bottomMargin: 10;
		anchors.left: db4.left;
		anchors.right: db4.right;
		property bool show;
		opacity: options.show ? 1 : 0;
		
		Behavior on opacity	{ Animation { duration: 500; } }

		GreenButton {
			height: mainWindow.height / 9;
			width: parent.width;
			text: "TTX";
		}
	
		GreenButton {
			height: mainWindow.height / 9;
			width: parent.width;
			text: "Sub";
		}
	
		GreenButton {
			height: mainWindow.height / 9;
			width: parent.width;
			text: "Audio";
		}
	}

	Protocol {
		id: protocol;
		clientId: "er_ottweb_device";
		deviceId: "123";
		ssoSystem: "er";
	}
}
