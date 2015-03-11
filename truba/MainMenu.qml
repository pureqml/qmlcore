Activity {
	name: "mainMenu";
	opacity: active ? 1.0 : 0.0;

	Column{
		anchors.left: parent.left;
		anchors.top: parent.top;
//		anchors.verticalCenter: parent.verticalCenter;
		width: parent.active ? 240 : 0;
		spacing: 8;

		FocusablePanel {
			id: channelList;
			anchors.left: parent.left;
			height: 120;
			width: parent.width;
			clip: true;

			Text {
				anchors.verticalCenter: parent.verticalCenter;
				anchors.left: parent.left;
				anchors.right: parent.right;
				horizontalAlignment: 2;
				text: "Список каналов";
				font.pointSize: 20;
				color: "white";
			}
		}

		FocusablePanel {
			id: epg;
			anchors.left: parent.left;
			height: 120;
			width: parent.width;
			clip: true;

			Text {
				anchors.verticalCenter: parent.verticalCenter;
				anchors.left: parent.left;
				anchors.right: parent.right;
				horizontalAlignment: 2;
				text: "Телегид";
				font.pointSize: 20;
				color: "white";
			}
		}

		FocusablePanel {
			id: settings;
			anchors.left: parent.left;
			height: 120;
			width: parent.width;
			clip: true;

			Text {
				anchors.verticalCenter: parent.verticalCenter;
				anchors.left: parent.left;
				anchors.right: parent.right;
				horizontalAlignment: 2;
				text: "Настройки";
				font.pointSize: 20;
				color: "white";
			}
		}

		Behavior on width { Animation { duration: 300; } }
	}

	Behavior on opacity { Animation { duration: 300; } }
}
