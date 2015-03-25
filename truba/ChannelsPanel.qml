Activity {
	id: channelsPanelProto;
	signal channelSwitched;
	property Protocol protocol;
	visible: active;
	anchors.fill: parent;
	name: "channelspanel";

	CategoriesModel { id: categoriesModel; protocol: channelsPanelProto.protocol; }
	ChannelsModel { id: channelsModel; protocol: channelsPanelProto.protocol; }

	CategoriesList {
		id: channelsPanelCategories;
		model: categoriesModel;
		spacing: 1;

		onCountChanged: {
			if (this.count > 1 && !channelsPanelChannels.count)
				channelsModel.setList(categoriesModel.get(0).list);
		}

		onDownPressed:		{ channelsPanelChannels.forceActiveFocus(); }
		onUpPressed:		{ channelsPanelProto.toMenuReturned(); }
		onClicked:			{ this.updateList(); }
		onSelectPressed:	{ this.updateList(); }
		updateList:			{ channelsModel.setList(categoriesModel.get(this.currentIndex).list); }
	}

	ChannelsList {
		id: channelsPanelChannels;
		anchors.top: channelsPanelCategories.bottom;
		anchors.topMargin: 1;
		spacing: 1;
		model: channelsModel;

		onUpPressed:		{ channelsPanelCategories.forceActiveFocus(); }
		switchTuCurrent:	{ channelsPanelProto.channelSwitched(this.model.get(this.currentIndex)); }
		onSelectPressed:	{ this.switchTuCurrent(); }
		onClicked:			{ this.switchTuCurrent(); }
	}

	Behavior on opacity { Animation { duration: 300; } }
}
