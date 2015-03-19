Item {
	id: channelsPanelProto;
	signal channelSwitched;
	property Protocol protocol;
	anchors.fill: parent;

	CategoriesModel { id: categoriesModel; protocol: channelsPanelProto.protocol; }
	ChannelsModel { id: channelsModel; protocol: channelsPanelProto.protocol; }

	Rectangle {
		anchors.fill: channelsPanelCategories;
		color: colorTheme.backgroundColor;
	}

	CategoriesList {
		id: channelsPanelCategories;
		model: categoriesModel;

		onCountChanged: {
			if (this.count == 1) {
				var self = this;
				categoriesModel.getList(function(res) {
					self.channelsModel.setList(res);
				})
			}
		}

		onDownPressed: { channelsPanelChannels.forceActiveFocus(); }
		onUpPressed: { channelsPanelProto.toMenuReturned(); }
	}

	Rectangle {
		anchors.fill: channelsPanelChannels;
		color: colorTheme.backgroundColor;
	}

	ChannelsList {
		id: channelsPanelChannels;
		anchors.top: channelsPanelCategories.bottom;
		anchors.topMargin: 1;
		model: channelsModel;

		onUpPressed: { channelsPanelCategories.forceActiveFocus(); }
		switchTuCurrent: { channelsPanelProto.channelSwitched(this.model.get(this.currentIndex).url); }
		onSelectPressed: { this.switchTuCurrent(); }
		onClicked: { this.switchTuCurrent(); }
	}

	Behavior on opacity { Animation { duration: 300; } }
}
