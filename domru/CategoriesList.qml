ListView {
	id: categoriesListProto;
	height: 70;
	anchors.top: parent.top;
	anchors.left: parent.left;
	anchors.right: parent.right;
	spacing: 10;
	orientation: 1;
	protocol: Protocol { enabled: true; }
	model: ChannelListModel {
		protocol: categoriesListProto.protocol;
		onCountChanged: { console.log("loaded " + this.count + " channel lists, using 0"); channelModel.setList(this.get(0)); }
	}
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

