Activity {
	id: mainMenuProto;
	signal optionChoosed;
	name: "mainMenu";
	opacity: active ? 1.0 : 0.0;

	Column{
		anchors.left: parent.left;
		anchors.top: parent.top;
		anchors.topMargin: 20;
		width: parent.active ? 260 : 0;
		spacing: 4;

		MenuButton {
			id: channelList;
			anchors.left: parent.left;
			width: parent.width;
			source: "res/pipeline.png";
			text: "Список каналов";

			onTriggered: { mainMenuProto.optionChoosed("channelList"); }
		}

		MenuButton {
			id: epg;
			anchors.left: parent.left;
			width: parent.width;
			source: "res/pipeline.png";
			text: "Телегид";

			onTriggered: { mainMenuProto.optionChoosed("epg"); }
		}

		MenuButton {
			id: movies;
			anchors.left: parent.left;
			width: parent.width;
			source: "res/pipeline.png";
			text: "Кино";

			onTriggered: { mainMenuProto.optionChoosed("movies"); }
		}

		MenuButton {
			id: settings;
			anchors.left: parent.left;
			width: parent.width;
			source: "res/pipeline.png";
			text: "Настройки";

			onTriggered: { mainMenuProto.optionChoosed("settings"); }
		}

		Behavior on width { Animation { duration: 300; } }
	}

	Behavior on opacity { Animation { duration: 300; } }
}
