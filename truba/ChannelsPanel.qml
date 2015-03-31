Activity {
	id: channelsPanelProto;
	signal channelSwitched;
	property Protocol protocol;
	visible: active;
	anchors.fill: parent;
	name: "channelspanel";

	CategoriesModel	{ id: categoriesModel; }
	ProvidersModel	{ id: providersModel; protocol: channelsPanelProto.protocol; }
	ChannelsModel	{ id: channelsModel; }

	ListView {
		id: channelsPanelProviders;
		height: 50;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.right: parent.right;
		orientation: ListView.Horizontal;
		clip: true;
		delegate: IconTextDelegate { }
		model: providersModel;

		onCountChanged: {
			if (this.count > 1 && !channelsPanelCategories.count)
				categoriesModel.setGenres(providersModel.get(0).genres);
		}

		onDownPressed:		{ channelsPanelCategories.forceActiveFocus(); }
		onClicked:			{ this.updateList(); }
		onSelectPressed:	{ this.updateList(); }

		updateList: {
			categoriesModel.setGenres(providersModel.get(this.currentIndex).genres);
			channelsModel.setList(categoriesModel.get(0).list);
		}
	}

	CategoriesList {
		id: channelsPanelCategories;
		anchors.top: channelsPanelProviders.bottom;
		anchors.topMargin: 1;
		model: categoriesModel;
		spacing: 1;

		onCountChanged: {
			if (this.count > 1 && !channelsPanelChannels.count)
				channelsModel.setList(categoriesModel.get(0).list);
		}

		onDownPressed:		{ channelsPanelChannels.forceActiveFocus(); }
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

		switchTuCurrent:	{ channelsPanelProto.channelSwitched(this.model.get(this.currentIndex)); }
		onSelectPressed:	{ this.switchTuCurrent(); }
		onClicked:			{ this.switchTuCurrent(); }

		onUpPressed: {
			if (this.currentIndex - this.columns >= 0)
				this.currentIndex -= this.columns;
			else
				channelsPanelCategories.forceActiveFocus();
		}
	}

	Behavior on opacity { Animation { duration: 300; } }
}
