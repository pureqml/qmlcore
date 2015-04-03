Activity {
	id: channelsPanelProto;
	signal channelSwitched;
	property Protocol protocol;
	visible: active;
	anchors.fill: parent;
	name: "channelspanel";

	CategoriesModel	{ id: categoriesModel; protocol: channelsPanelProto.protocol; }
	ChannelsModel	{ id: channelsModel; }

	CategoriesList {
		id: channelsPanelCategories;
		anchors.top: parent.top;
		anchors.left: parent.left;
		model: categoriesModel;
		spacing: 1;

		onCountChanged: {
			if (this.count > 1 && !channelsPanelChannels.count)
				channelsModel.setList(categoriesModel.get(0).list);
		}

		onRightPressed: {
			channelsPanelChannels.currentIndex = 0;
			channelsPanelChannels.forceActiveFocus();
		}

		onLeftPressed:		{ channelsPanelProviders.forceActiveFocus(); }
		onClicked:			{ this.updateList(); }
		onSelectPressed:	{ this.updateList(); }
		updateList:			{ channelsModel.setList(categoriesModel.get(this.currentIndex).list); }
	}

	ChannelsList {
		id: channelsPanelChannels;
		anchors.top: channelsPanelCategories.top;
		anchors.left: channelsPanelCategories.right;
		anchors.leftMargin: 1;
		spacing: 1;
		model: channelsModel;

		switchTuCurrent:	{ channelsPanelProto.channelSwitched(this.model.get(this.currentIndex)); }
		onSelectPressed:	{ this.switchTuCurrent(); }
		onClicked:			{ this.switchTuCurrent(); }

		onLeftPressed: {
			log(this.currentIndex % this.columns);
			if (this.currentIndex % this.columns)
				this.currentIndex--;
			else
				channelsPanelCategories.forceActiveFocus();
		}
	}

	Behavior on opacity { Animation { duration: 300; } }
}
