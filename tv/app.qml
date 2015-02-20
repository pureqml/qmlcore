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
