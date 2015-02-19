Item {
	id: mainWindow;
	anchors.fill: renderer;
	anchors.leftMargin: 75;
	anchors.rightMargin: 75;
	anchors.bottomMargin: 40;
	anchors.topMargin: 42;

	Column {
		id: bottomPanel;
		property int innerHeight: 68;
		anchors.bottom: parent.bottom;
		anchors.bottomMargin: footer.top;
		anchors.left: parent.left;
		anchors.right: parent.right;
		spacing: 8;

		GreenButton {
			id: timePanel;
			height: bottomPanel.innerHeight;
			width: 144;
			anchors.bottom: parent.bottom;
			anchors.left: parent.left;

			Text {
				anchors.top: parent.top;
				anchors.left: parent.left;
				anchors.topMargin: 12;
				anchors.leftMargin: 10;
				color: "#fff";
				text: "15:19";
			}

			Text {
				anchors.bottom: parent.bottom;
				anchors.left: parent.left;
				anchors.bottomMargin: 12;
				anchors.leftMargin: 10;
				color: "#ccc";
				text: "22 сентября Пн";
			}
		}

		GreenButton {
			id: channelPanel;
			height: bottomPanel.innerHeight;
			width: 144;
			anchors.bottom: parent.bottom;
			anchors.left: timePanel.right;
			anchors.leftMargin: bottomPanel.spacing;

			Text {
				anchors.top: parent.top;
				anchors.left: parent.left;
				anchors.topMargin: 12;
				anchors.leftMargin: 10;
				color: "#ccc";
				text: "015";
			}
		}

		GreenButton {
			id: programPanel;
			height: bottomPanel.innerHeight;
			width: 675;
			anchors.bottom: parent.bottom;
			anchors.left: channelPanel.right;
			anchors.leftMargin: bottomPanel.spacing;

			Text {
				id: programText;
				anchors.top: parent.top;
				anchors.left: parent.left;
				anchors.right: parent.right;
				anchors.topMargin: 12;
				anchors.leftMargin: 10;
				anchors.rightMargin: 10;
				color: "#fff";
				text: "Название текущей передачи";
			}

			Text {
				anchors.top: programText.bottom;
				anchors.left: parent.left;
				anchors.right: parent.right;
				anchors.leftMargin: 10;
				anchors.rightMargin: 10;
				color: "#ccc";
				text: "8:45 - 9:00, Россия 2, Спорт, 18";
			}
		}

		GreenButton {
			id: settingsButton;
			height: bottomPanel.innerHeight;
			width: height;
			anchors.bottom: parent.bottom;
			anchors.left: programPanel.right;
			anchors.leftMargin: bottomPanel.spacing;
		}

		GreenButton {
			id: exitButton;
			height: bottomPanel.innerHeight;
			width: height;
			anchors.bottom: parent.bottom;
			anchors.left: settingsButton.right;
			anchors.leftMargin: bottomPanel.spacing;
		}
	}

	Item {
		id: footer;
		height: 20;
		anchors.bottom: parent.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;
	}

	ListModel {
		id: contextModel;
		property string text;
		property Color color;

		ListElement {
			text: "ТВ Гид";
			color: "#f00";
		}

		ListElement {
			text: "Список каналов";
			color: "#0f0";
		}
	}

	ContextMenu {
		model: contextModel;
	}
}
