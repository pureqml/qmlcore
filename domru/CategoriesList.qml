Item {
	id: channelList;
	property Protocol protocol;

	ChannelListModel {
		id: channelListModel;
		protocol: channelList.protocol;
		onCountChanged: { console.log("loaded " + this.count + " channel lists, using 0"); channelModel.setList(this.get(0)); }
	}

	ChannelModel {
		id: channelModel;
		protocol: channelList.protocol;
	}

	ListView {
		id: categoriesList;
		height: 70;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.right: parent.right;
		spacing: 10;
		orientation: 1;

		model: channelListModel;

		delegate: Item {
			width: categoryName.paintedWidth + 20;
			height: parent.height;

			Text {
				id: categoryName;
				font.pixelSize: 40;
				anchors.centerIn: parent;
				text: model.asset ? model.asset.title : "";
				color: "#fff";
				opacity: parent.activeFocus ? 1.0 : 0.6;
			}
		}
	}

	ListView {
		focus: true;
		model : channelModel;
		delegate: Item {
			width: categoryName.paintedWidth + 20;
			height: 45;

			Text {
				id: categoryName;
				font.pixelSize: 40;
				anchors.centerIn: parent;
				text: model.asset ? model.asset.title : "";
				color: "#fff";
				opacity: parent.activeFocus ? 1.0 : 0.6;
			}
		}

		anchors.top: categoriesList.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
	}
}
