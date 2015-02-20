Item {
	id: mainWindow;
	anchors.fill: renderer;
	anchors.leftMargin: 75;
	anchors.rightMargin: 75;
	anchors.bottomMargin: 40;
	anchors.topMargin: 42;

	InfoPlate {
		anchors.fill: parent;
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
			clip: true;
			Text {
				font.pixelSize: 40;
				anchors.centerIn: parent;
				text: model.asset? model.asset.title: "";
			}
		}
	}
}
