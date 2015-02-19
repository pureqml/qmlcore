Item {
	id: mainWindow;
	anchors.fill: renderer;
	anchors.leftMargin: 75;
	anchors.rightMargin: 75;
	anchors.bottomMargin: 40;
	anchors.topMargin: 42;

	Item {
		height: channelNumber.height;
		anchors.top: parent.top;
		anchors.right: parent.right;
		anchors.left: parent.left;

		Image {
			id: logo;
			anchors.top: parent.top;
			anchors.left: parent.left;
			source: "res/logoDomru.png";
		}

		Rectangle {
			id: channelNumber;
			width: 125;
			height: 68;
			anchors.top: parent.top;
			anchors.right: parent.right;
			color: "#000c";
		}

		Text {
			anchors.centerIn: channelNumber;
			font.pointSize: 24;
			text: "14";
			color: "#fff";
		}
	}

	Row {
		id: bottomPanel;
		property int innerHeight: 68;
		anchors.bottom: footer.top;
		anchors.bottomMargin: 35;
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

			ProgressBar {
				anchors.bottom: parent.bottom;
				anchors.left: parent.left;
				anchors.right: parent.right;
				progress: 0.5;
			}
		}

		GreenButton {
			id: settingsButton;
			height: bottomPanel.innerHeight;
			width: height;
			anchors.bottom: parent.bottom;
			anchors.left: programPanel.right;
			anchors.leftMargin: bottomPanel.spacing;

			Image {
				anchors.centerIn: parent;
				source: "res/settings.png";
			}
		}

		GreenButton {
			id: shareButton;
			height: bottomPanel.innerHeight;
			width: height;
			anchors.bottom: parent.bottom;
			anchors.left: settingsButton.right;
			anchors.leftMargin: bottomPanel.spacing;

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

		Options { model: optionsModel; }
	}

	Protocol {
		id : proto;
	}

	ChannelModel {
		id: channelModel;
		protocol: proto;
	}

	ChannelListModel {
		protocol : proto;
		onCountChanged: { console.log("loaded " + this.count + " channel lists, using 0"); channelModel.setList(this.get(0)); }
	}

	ListView {
		anchors.fill: parent;
		anchors.margins: 100;

		model: channelModel;
		delegate: Rectangle {
			width: parent.width;
			height: 50;
			color: "white";
			Text {
				font.pixelSize: 40;
				anchors.centerIn: parent;
				text: model.asset? model.asset.title: "";
			}
		}
	}
}
