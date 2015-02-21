Item {
	id: channelList;
	property Protocol protocol;
	property bool active: false;

	signal activated(url);

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
		opacity: channelList.active ? 1.0 : 0.0;
		model: channelListModel;
		delegate: Item {
			width: categoryName.paintedWidth + 20;
			height: parent.height;

			Text {
				id: categoryName;
				font.pixelSize: 40;
				anchors.centerIn: parent;
				text: model.name;
				color: "#f00";
				opacity: parent.activeFocus ? 1.0 : 0.6;
			}
		}

		onDownPressed: { channelView.forceActiveFocus(); }

		Behavior on opacity { Animation { duration: 300; } }
	}

	ListView {
		id: channelView;
		anchors.top: categoriesList.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		focus: true;
		opacity: channelList.active ? 1.0 : 0.0;
		model : channelModel;
		delegate: Rectangle {
			width: categoryName.paintedWidth + 20;
			color: "#000c";
			height: 45;

			Text {
				id: categoryName;
				font.pixelSize: 24;
				anchors.centerIn: parent;
				text: model.asset ? model.asset.title : "";
				color: "#fff";
				opacity: parent.activeFocus ? 1.0 : 0.6;
			}
		}

		Behavior on opacity { Animation { duration: 300; } }
		onSelectPressed: {
			var activated = channelList.activated
			this.model.getUrl(this.currentIndex, function(url) {
				activated(url)
			})
		}
	}

	toggle: {
		channelList.active = !channelList.active;
		if (channelList.active)
			categoriesList.forceActiveFocus();
	}
}
