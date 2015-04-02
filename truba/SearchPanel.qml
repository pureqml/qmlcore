Activity {
	id: searchPanelProto;
	signal channelSwitched;
	property Protocol protocol;
	property string searchRequest;
	property Array channels;
	anchors.fill: parent;
	visible: active;
	name: "search";

	ListModel { id: foundChannelModel; }

	Column {
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.right: parent.right;
		spacing: 1;

		Rectangle {
			height: 100;
			width: parent.width;
			color: colorTheme.backgroundColor;

			Text {
				id: foundChannelsLabel;
				anchors.verticalCenter: parent.verticalCenter;
				anchors.left: parent.left;
				anchors.leftMargin: 10;
				color: colorTheme.textColor;
				font.pointSize: 32;
				text: "Каналы:";
			}

			ListView {
				id: foundChannelsResult;
				height: parent.height;
				anchors.left: foundChannelsLabel.right;
				anchors.right: parent.right;
				anchors.leftMargin: 10;
				orientation: ListView.Horizontal;
				clip: true;
				model: foundChannelModel;
				delegate: ChannelDelegate { }

				onSelectPressed:	{ this.switchTuCurrent(); }
				onClicked:			{ this.switchTuCurrent(); }

				switchTuCurrent:	{
					if (!this.count)
						return;
					searchPanelProto.stop();
					searchPanelProto.channelSwitched(this.model.get(this.currentIndex));
				}
			}
		}

		Rectangle {
			height: 100;
			width: parent.width;
			color: colorTheme.backgroundColor;

			Text {
				anchors.verticalCenter: parent.verticalCenter;
				anchors.left: parent.left;
				anchors.leftMargin: 10;
				color: colorTheme.textColor;
				font.pointSize: 32;
				text: "Передачи:";
			}
		}

		Rectangle {
			height: 100;
			width: parent.width;
			color: colorTheme.backgroundColor;

			Text {
				anchors.verticalCenter: parent.verticalCenter;
				anchors.left: parent.left;
				anchors.leftMargin: 10;
				color: colorTheme.textColor;
				font.pointSize: 32;
				text: "Кино:";
			}
		}

		Rectangle {
			height: 100;
			width: parent.width;
			color: colorTheme.backgroundColor;

			Text {
				anchors.verticalCenter: parent.verticalCenter;
				anchors.left: parent.left;
				anchors.leftMargin: 10;
				color: colorTheme.textColor;
				font.pointSize: 32;
				text: "Провайдеры:";
			}
		}
	}

	search: {
		foundChannelModel.clear();
		var request = searchPanelProto.searchRequest.toLowerCase();
		if (!request.length)
			return;

		if (!this.channels || !this.channels.length) {
			log("There are no channels.");
			return;
		}

		log("Search: " + request);

		var list = this.channels;
		for (var i in list)
			if (list[i].title.toLowerCase().indexOf(request) >= 0)
				foundChannelModel.append({
					text:	list[i].title,
					url:	list[i].url,
					lcn:	list[i].lcn,
					source:	list[i].icon ? "http://truba.tv" + list[i].icon.source : "",
					color:	list[i].icon ? list[i].icon.color : "#0000"
				});
	}

	onVisibleChanged: {
		if (!this.visible) {
			this.searchRequest = "";
			return;
		}

		foundChannelModel.clear();
		foundChannelsResult.contentX = 0;

		var protocol = this.protocol;
		if (!protocol)
			return;

		var self = this;
		protocol.getChannels(function(res) {
			self.channels = res;
			self.search();
		})
	}
}
