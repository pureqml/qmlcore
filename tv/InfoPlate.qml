Item {
	id: infoPlateItem;
	anchors.fill: parent;
	property int channelNumber: 20;


	Rectangle {
		anchors.bottom: renderer.bottom;
		anchors.left: renderer.left;
		anchors.right: renderer.right;
		height: 210;

		gradient: Gradient {
			GradientStop { color: "#FFFFFFFF"; position: 0; } //TODO: fixme
			GradientStop { color: "black"; position: 1; }
		}
	}

	Image {
		id: logo;
		anchors.top: parent.top;
		anchors.left: parent.left;
		source: "res/logoDomru.png";
	}

	Rectangle {
		width: 125;
		height: 68;
		anchors.top: parent.top;
		anchors.right: parent.right;
		opacity: 0.6;
		color: "#000000";

		Text {
			anchors.centerIn: parent;
			font.pointSize: 32;
			text: infoPlateItem.channelNumber;
			color: "#fff";
		}
	}

	Item {
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.bottom: footer.top;
		anchors.bottomMargin: 35;

		GreenButton {
			id: timePanel;
			height: 68;
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
			height: 68;
			width: 144;
			anchors.bottom: parent.bottom;
			anchors.left: timePanel.right;
			anchors.leftMargin: 8;

			Text {
				anchors.top: parent.top;
				anchors.left: parent.left;
				anchors.topMargin: 12;
				anchors.leftMargin: 10;
				color: "#ccc";
				text: "015";
			}

			Image {
				anchors.right: parent.right;
				anchors.top: parent.top;
				anchors.topMargin: 12;
				anchors.rightMargin: 10;
				source: "res/chanelLogo.png";
			}

			Image {
				id: hdLogo;
				anchors.left: parent.left;
				anchors.bottom: parent.bottom;
				anchors.bottomMargin: 12;
				anchors.leftMargin: 10;
				source: "res/hd.png";
			}

			Image {
				anchors.left: hdLogo.right;
				anchors.bottom: parent.bottom;
				anchors.bottomMargin: 12;
				anchors.leftMargin: 10;
				source: "res/3d.png";
			}

			Image {
				anchors.right: parent.right;
				anchors.bottom: parent.bottom;
				anchors.bottomMargin: 12;
				anchors.rightMargin: 10;
				source: "res/lock.png";
			}
		}

		GreenButton {
			id: programPanel;
			height: 68;
			width: 675;
			anchors.bottom: parent.bottom;
			anchors.left: channelPanel.right;
			anchors.right: settingsButton.left;
			anchors.leftMargin: 8;
			anchors.rightMargin: 8;

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

			ProgressBar {
				anchors.bottom: parent.bottom;
				anchors.left: parent.left;
				anchors.right: parent.right;
				progress: 0.5;
			}
		}

		GreenButton {
			id: settingsButton;
			height: 68;
			width: height;
			anchors.bottom: parent.bottom;
			anchors.right: shareButton.left;
			anchors.rightMargin: 8;

			Image {
				anchors.centerIn: parent;
				source: "res/settings.png";
			}
		}

		GreenButton {
			id: shareButton;
			height: 68;//bottomPanel.innerHeight;
			width: height;
			anchors.bottom: parent.bottom;
			anchors.right: parent.right;

			Image {
				anchors.centerIn: parent;
				source: "res/share.png";
			}
		}
	}

	Item {
		id: footer;
		height: 20;
		anchors.bottom: parent.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;

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
				color: "#00ab5f";
			}
		}

		ContextMenu { model: contextModel; }

		ListModel {
			id: optionsModel;
			property string text;
			property string source;

			ListElement {
				text: "Назад";
				source: "res/back.png";
			}

			ListElement {
				text: "ТВ меню";
				source: "res/qMenu.png";
			}

			ListElement {
				text: "Выход";
				source: "res/exit.png";
			}
		}

		Options { 
			model: optionsModel; 
//			anchors.right: parent.right;
//			anchors.bottom: parent.bottom;
		}
	}	
}