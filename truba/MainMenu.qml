Item {
	id: mainMenuProto;
	signal optionChoosed;
	signal closeAll;
	name: "mainMenu";
	property bool active;
	property bool open;
	opacity: active ? 1 : 0;

	MenuButton {
		id: menuButton;
		anchors.left: parent.left;
		anchors.top: parent.top;
		height: 70;
		text: "Truba\.TV";
		z: 10;

		onTriggered: {
			if (!mainMenuProto.open) {
				mainMenuProto.open = true;
			}
			else {
				mainMenuProto.open = false;
			}
		}
	}

	MenuButton {
		id: exitButton;
		anchors.right: parent.right;
		anchors.top: parent.top;
		height: 70;
		text: "Exit";
		z: 10;

		onTriggered: {
			mainMenuProto.open = false;
			mainMenuProto.closeAll();
		}
	}

	Column{
		anchors.left: parent.left;
		anchors.top: menuButton.bottom;
		anchors.topMargin: mainMenuProto.open && mainMenuProto.active ? 2 : -500;
		width: 260;
		spacing: 2;
		z: 9;

		MenuButton {
			id: channelList;
			anchors.left: parent.left;
			width: parent.width;
			source: "res/pipeline.png";
			text: "Список каналов";

			onTriggered: { mainMenuProto.open = false; mainMenuProto.optionChoosed("channelList"); }
		}

		MenuButton {
			id: epg;
			anchors.left: parent.left;
			width: parent.width;
			source: "res/pipeline.png";
			text: "Телегид";

			onTriggered: { mainMenuProto.open = false; mainMenuProto.optionChoosed("epg"); }
		}

		MenuButton {
			id: movies;
			anchors.left: parent.left;
			width: parent.width;
			source: "res/pipeline.png";
			text: "Кино";

			onTriggered: { mainMenuProto.open = false; mainMenuProto.optionChoosed("movies"); }
		}

		MenuButton {
			id: settings;
			anchors.left: parent.left;
			width: parent.width;
			source: "res/pipeline.png";
			text: "Настройки";

			onTriggered: { mainMenuProto.open = false; mainMenuProto.optionChoosed("settings"); }
		}

		Behavior on y { Animation { duration: 200; } }
	}

	Behavior on opacity { Animation { duration: 300; } }
}
