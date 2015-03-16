Activity {
	id: channelsPanelProto;
	signal channelSwitched;
	property Protocol protocol;
	anchors.top: parent.top;
	anchors.bottom: parent.bottom;
	anchors.left: parent.left;
	active: false;
	opacity: active ? 1.0 : 0.0;

	CategoriesModel { id: categoriesModel; protocol: channelsPanelProto.protocol; }
	ChannelsModel { id: channelsModel; protocol: channelsPanelProto.protocol; }

	Rectangle {
		anchors.fill: channelsPanelChannels;
		color: colorTheme.backgroundColor;
	}

	ChannelsList {
		id: channelsPanelChannels;
		anchors.left: channelsPanelCategories.left;
		anchors.leftMargin: 50;
		model: channelsModel;

		onLeftPressed: { channelsPanelCategories.forceActiveFocus(); }
		onSelectPressed: { channelsPanelProto.channelSwitched(this.model.get(this.currentIndex).url); }
	}

	Rectangle {
		anchors.fill: channelsPanelChannels;
		color: "#000";
		opacity: channelsPanelChannels.activeFocus ? 0.0 : 0.6;

		Behavior on opacity { Animation { duration: 300; } }
	}

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

		onRightPressed: { channelsPanelChannels.forceActiveFocus(); }
	}

	onActiveChanged: {
		if (this.active)
			categoriesModel.update();
	}

	Behavior on opacity { Animation { duration: 300; } }
}
