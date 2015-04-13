Activity {
	id: channelsPanelProto;
	signal channelSwitched;
	visible: active;
	anchors.fill: parent;
	name: "channelspanel";

	ChannelsModel	{ id: channelsModel; }

	CategoriesList {
		id: channelsPanelCategories;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.bottom: parent.bottom;
		model: categoriesModel;
		spacing: 1;

		onCountChanged: {
			if (this.count > 1 && !channelsPanelChannels.count)
				channelsModel.setList(channelsPanelCategories.model.get(0).list);
		}

		onRightPressed: {
			channelsPanelChannels.currentIndex = 0;
			channelsPanelChannels.forceActiveFocus();
		}

		onClicked:			{ this.updateList(); }
		onSelectPressed:	{ this.updateList(); }
		updateList:			{ channelsModel.setList(channelsPanelCategories.model.get(this.currentIndex).list); }
	}

	ChannelsList {
		id: channelsPanelChannels;
		anchors.top: channelsPanelCategories.top;
		anchors.left: channelsPanelCategories.right;
		anchors.leftMargin: 1;
		spacing: 1;
		visible: categoriesModel.count;
		model: channelsModel;

		switchTuCurrent:	{ channelsPanelProto.channelSwitched(this.model.get(this.currentIndex)); }
		onSelectPressed:	{ this.switchTuCurrent(); }
		onClicked:			{ this.switchTuCurrent(); }

		onLeftPressed: {
			if (this.currentIndex % this.columns)
				this.currentIndex--;
			else
				channelsPanelCategories.forceActiveFocus();
		}
	}

	Behavior on opacity { Animation { duration: 300; } }
}
