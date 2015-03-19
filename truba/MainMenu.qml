Item {
	id: mainMenuProto;
	signal optionChoosed;
	signal closeAll;
	name: "mainMenu";
	property bool active;
	opacity: active ? 1 : 0;
	height: 60;

	Row {
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.right: fullscreenButton.left;
		height: parent.height;

		TextButton {
			id: channelList;
			text: "Каналы";

			onActiveFocusChanged: { if (this.activeFocus) mainMenuProto.optionChoosed("channelList"); }
		}

		TextButton {
			id: epg;
			text: "Телегид";

			onActiveFocusChanged: { if (this.activeFocus) mainMenuProto.optionChoosed("epg"); }
		}

		TextButton {
			id: movies;
			text: "Кино";

			onActiveFocusChanged: { if (this.activeFocus) mainMenuProto.optionChoosed("movies"); }
		}

		TextButton {
			id: settings;
			text: "Настройки";

			onActiveFocusChanged: { if (this.activeFocus) mainMenuProto.optionChoosed("settings"); }
		}
	}

	TextButton {
		id: fullscreenButton;
		anchors.right: exitButton.left;
		anchors.top: parent.top;
		height: 60;
		focusOnHover: true;
		text: "Fullscreen";

		onTriggered: {
			console.log("entering fullscreen mode");
			if (renderer.inFullscreenMode())
				renderer.exitFullscreenMode();
			else
				renderer.enterFullscreenMode();
		}
	}

	TextButton {
		id: exitButton;
		anchors.right: parent.right;
		anchors.top: parent.top;
		height: 60;
		focusOnHover: true;
		text: "Exit";

		onTriggered: { mainMenuProto.closeAll(); }
	}

	Behavior on opacity { Animation { duration: 250; } }
}
