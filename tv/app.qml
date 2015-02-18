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

		onRightPressed: { db2.forceActiveFocus(); }
	}

	DomButton {
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

	DomButton {
		id: db3;
		anchors.bottom: parent.bottom;
		anchors.left: db2.right;
		anchors.right: db4.left;
		anchors.leftMargin: parent.width / 100;
		anchors.rightMargin: parent.width / 100;
		height: activeFocus ? 200 : db1.height;
		text: "No targets specified and no makefile found.";

		onRightPressed: { db4.forceActiveFocus(); }
		onLeftPressed: { db2.forceActiveFocus(); }
	}

	DomButton {
		id: db4;
		anchors.bottom: parent.bottom;
		anchors.right: db5.left;
		anchors.rightMargin: parent.width / 100;
		height: parent.height / 9;
		width: parent.width / 16;
		text: "Options";

		onRightPressed: { db5.forceActiveFocus(); }
		onLeftPressed: { db3.forceActiveFocus(); }

		onTriggered: {
			options.showed = !options.showed;
			// if (options.opacity > 0)
			// 	options.opacity = 0;
			// else
			// 	opacity.opacity = 1;
		}
	}

	DomButton {
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
		property bool showed;
		opacity: options.showed ? 1 : 0;
		
		Behavior on opacity	{ Animation { duration: 500; } }

		DomButton {
			height: mainWindow.height / 9;
			width: parent.width;
			text: "TTX";
		}
	
		DomButton {
			height: mainWindow.height / 9;
			width: parent.width;
			text: "Sub";
		}
	
		DomButton {
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
