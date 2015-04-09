Activity {
	id: searchPanelProto;
	signal channelSwitched;
	property Protocol protocol;
	property string searchRequest;
	anchors.fill: parent;
	visible: active;
	name: "search";

	ListModel { id: foundChannelModel; }
	ListModel { id: foundProgramsModel; }

	Rectangle {
		id: foundChannelsPanel;
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
			anchors.top: parent.top;
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
		id: foundProgramsPanel;
		height: 100;
		width: parent.width;
		anchors.top: foundChannelsPanel.bottom;
		anchors.topMargin: 1;
		color: colorTheme.backgroundColor;

		Text {
			id: programsLabel;
			anchors.verticalCenter: parent.verticalCenter;
			anchors.left: parent.left;
			anchors.leftMargin: 10;
			color: colorTheme.textColor;
			font.pointSize: 32;
			text: "Передачи:";
		}

		ListView {
			id: foundProgramsResult;
			height: parent.height;
			anchors.top: parent.top;
			anchors.left: programsLabel.right;
			anchors.right: parent.right;
			anchors.leftMargin: 10;
			orientation: ListView.Horizontal;
			clip: true;
			model: foundProgramsModel;
			delegate: BaseButton {
				width: foundProgramText.paintedWidth + 10;
				height: parent.height;

				Text {
					id: foundProgramText;
					anchors.top: parent.top;
					text: model.title;
					color: colorTheme.textColor;
				}

				Text {
					anchors.top: foundProgramText.bottom;
					anchors.horizontalCenter: parent.horizontalCenter;
					text: model.start;
					color: colorTheme.textColor;
				}

				Text {
					anchors.bottom: parent.bottom;
					anchors.horizontalCenter: parent.horizontalCenter;
					text: model.channel;
					color: colorTheme.textColor;
				}
			}

			//onSelectPressed:	{ this.switchTuCurrent(); }
			//onClicked:			{ this.switchTuCurrent(); }

			//switchTuCurrent:	{
				//if (!this.count)
					//return;
				//searchPanelProto.stop();
				//searchPanelProto.channelSwitched(this.model.get(this.currentIndex));
			//}
		}
	}

	searchPrograms(programs): {
		foundProgramsModel.clear();
		var request = searchPanelProto.searchRequest.toLowerCase();
		if (!request.length)
			return;

		if (!programs || !programs.length) {
			log("There are no programs.");
			return;
		}

		log("Search in programs: " + request);

		for (var i in programs)
			if (programs[i].title.toLowerCase().indexOf(request) >= 0) {
				var start = new Date(programs[i].start);
				start = start.getHours() + ":" + (start.getMinutes() < 10 ? "0" : "") + start.getMinutes();
				foundProgramsModel.append({
					title: programs[i].title,
					channel: programs[i].channel,
					start: start
				});
			}

	}

	searchChannels(channels): {
		foundChannelModel.clear();
		var request = searchPanelProto.searchRequest.toLowerCase();
		if (!request.length)
			return;

		if (!channels || !channels.length) {
			log("There are no channels.");
			return;
		}

		log("Search: " + request);

		for (var i in channels)
			if (channels[i].title.toLowerCase().indexOf(request) >= 0)
				foundChannelModel.append({
					text:	channels[i].title,
					url:	channels[i].url,
					lcn:	channels[i].lcn,
					source:	channels[i].icon ? "http://truba.tv" + channels[i].icon.source : "",
					color:	channels[i].icon ? channels[i].icon.color : "#0000"
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
			self.searchChannels(res);
		})

		var self = this;
		protocol.getProgramsAtDate(new Date(), function(res) {
			self.searchPrograms(res);
		})
	}
}
