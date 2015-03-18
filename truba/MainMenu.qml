Item {
	id: mainMenuProto;
	signal optionChoosed;
	signal closeAll;
	name: "mainMenu";
	property bool active;
	opacity: active ? 1 : 0;

	Row {
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.right: fullscreenButton.left;
		height: 60;

		TextButton {
			id: channelList;
			text: "Каналы";

			onTriggered: { mainMenuProto.optionChoosed("channelList"); }
		}

		TextButton {
			id: epg;
			text: "Телегид";

			onTriggered: { mainMenuProto.optionChoosed("epg"); }
		}

		TextButton {
			id: movies;
			text: "Кино";

			onTriggered: { mainMenuProto.optionChoosed("movies"); }
		}

		TextButton {
			id: settings;
			text: "Настройки";

			onTriggered: { mainMenuProto.optionChoosed("settings"); }
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