Activity {
	id: mainMenuProto;
	signal optionChoosed;
	name: "mainMenu";
	opacity: active ? 1.0 : 0.0;

	MenuButton {
		id: menuButton;
		anchors.top: parent.top;
		anchors.left: parent.left;
		source: "res/trubaback.png";
		text: "TRUBA\.TV";

		onClicked: {
			if (this.parent.active)
				this.parent.stop();
		}
	}

	Column{
		anchors.left: parent.left;
		anchors.top: menuButton.bottom;
		anchors.topMargin: 20;
		width: parent.active ? 240 : 0;
		spacing: 8;

		MenuButton {
			id: channelList;
			anchors.left: parent.left;
			height: 120;
			width: parent.width;
			source: "res/pipeline.png";
			text: "Список каналов";

			onTriggered: { mainMenuProto.optionChoosed("channelList"); }
		}

		MenuButton {
			id: epg;
			anchors.left: parent.left;
			height: 120;
			width: parent.width;
			source: "res/pipeline.png";
			text: "Телегид";

			onTriggered: { mainMenuProto.optionChoosed("epg"); }
		}

		MenuButton {
			id: movies;
			anchors.left: parent.left;
			height: 120;
			width: parent.width;
			source: "res/pipeline.png";
			text: "Кино";

			onTriggered: { mainMenuProto.optionChoosed("movies"); }
		}

		MenuButton {
			id: settings;
			anchors.left: parent.left;
			height: 120;
			width: parent.width;
			source: "res/pipeline.png";
			text: "Настройки";

			onTriggered: { mainMenuProto.optionChoosed("settings"); }
		}

		Behavior on width { Animation { duration: 300; } }
	}

	Behavior on opacity { Animation { duration: 300; } }
}
