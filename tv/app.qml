Item {
	id: mainWindow;
	anchors.fill: renderer;
	anchors.leftMargin: 75;
	anchors.rightMargin: 75;
	anchors.bottomMargin: 40;
	anchors.topMargin: 42;

	InfoPlate {
		id: infoPlate;
		anchors.fill: parent;
	}

	Protocol {
		id : proto;
	}

	Text {
		anchors.centerIn: parent;
		text: "Нажми F2, штоп показать инфобаннер";
	}

	ChannelModel {
		id: channelModel;
		protocol: proto;
	}

	ChannelListModel {
		protocol : proto;
		onCountChanged: { console.log("loaded " + this.count + " channel lists, using 0"); channelModel.setList(this.get(0)); }
	}

	onKeyPressed: {
		infoPlate.active = true;
		hideTimer.restart();
	}

	ListView {
		anchors.fill: parent;
		anchors.margins: 100;

		model: channelModel;
		delegate: Rectangle {
			width: parent.width;
			height: 50;
			color: "white";
			clip: true;
			Text {
				font.pixelSize: 40;
				anchors.centerIn: parent;
				text: model.asset? model.asset.title: "";
			}
		}
	}
}
