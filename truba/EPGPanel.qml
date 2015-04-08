Activity {
	id: epgPanelProto;
	property Protocol protocol;
	signal channelSwitched;
	visible: active;
	anchors.fill: parent;
	name: "epgpanel";

	CategoriesModel	{ id: epgCategoriesModel; protocol: channelsPanelProto.protocol; }
	EPGModel		{ id: epgPanelEpgModel; protocol: channelsPanelProto.protocol; }
	ChannelsModel	{ id: epgChannelsModel; }

	CategoriesList {
		id: epgCategories;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.bottom: parent.bottom;
		model: epgCategoriesModel;
		spacing: 1;

		onCountChanged: {
			if (this.count > 1 && !epgPanelChannels.count)
				epgChannelsModel.setList(epgCategoriesModel.get(0).list);
		}

		onRightPressed: {
			epgPanelChannels.currentIndex = 0;
			epgPanelChannels.forceActiveFocus();
		}

		onClicked:			{ this.updateList(); }
		onSelectPressed:	{ this.updateList(); }
		updateList:			{ epgChannelsModel.setList(epgCategoriesModel.get(this.currentIndex).list); }
	}

	ScrollableListView {
		id: epgPanelChannels;
		width: 100;
		anchors.top: channelsPanelCategories.top;
		anchors.left: channelsPanelCategories.right;
		anchors.bottom: channelsPanelCategories.bottom;
		anchors.leftMargin: 1;
		spacing: 1;
		clip: true;
		scrollbarWidth: 10;
		model: epgChannelsModel;
		delegate: ChannelDelegate {
			widith: 100;
			height: 100;
		}

		onSelectPressed:	{ this.switchTuCurrent(); }
		onClicked:			{ this.switchTuCurrent(); }
		onLeftPressed:		{ epgCategories.forceActiveFocus(); }
		onRightPressed:		{ epgPanelProgramsList.forceActiveFocus(); }
		switchTuCurrent:	{ epgPanelProto.channelSwitched(this.model.get(this.currentIndex)); }

		onCurrentIndexChanged:	{ delayTimer.restart(); }

		Timer {
			id: delayTimer;
			interval: 500;

			onTriggered: {
				var channel = epgPanelChannels.model.get(epgPanelChannels.currentIndex).text;
				epgPanelEpgModel.getEPGForChannel(channel);
			}
		}
	}

	ScrollableListView {
		id: epgPanelProgramsList;
		anchors.top: channelsPanelCategories.top;
		anchors.left: epgPanelChannels.right;
		anchors.right: parent.right;
		anchors.bottom: channelsPanelCategories.bottom;
		anchors.leftMargin: 1;
		spacing: 1;
		clip: true;
		model: epgPanelEpgModel;
		delegate: BaseButton {
			width: parent.width;
			height: 50;

			Text {
				id: epgDelegaetTimeText;
				anchors.left: parent.left;
				anchors.verticalCenter: parent.verticalCenter;
				anchors.leftMargin: 10;
				color: colorTheme.textColor;
				text: model.start;
			}

			Text {
				anchors.left: epgDelegaetTimeText.right;
				anchors.verticalCenter: parent.verticalCenter;
				anchors.leftMargin: 10;
				color: colorTheme.textColor;
				text: model.title;
			}
		}

		onLeftPressed: { epgPanelChannels.forceActiveFocus(); }
	}

	Rectangle {
		anchors.fill: epgPanelProgramsList;
		color: colorTheme.backgroundColor;
		opacity: !epgPanelEpgModel.isBusy && !epgPanelProgramsList.count;

		Text {
			anchors.centerIn: parent;
			color: colorTheme.textColor;
			text: "Не удалось загрузить программу передач";
			font.pointSize: 18;
			wrap: true;
		}

		Behavior on opacity { Animation { duration: 300; } }
	}

	Image {
		anchors.centerIn: epgPanelProgramsList;
		source: "res/spinner.png";
		opacity: epgPanelEpgModel.isBusy && !epgPanelProgramsList.count;

		Behavior on opacity { Animation { duration: 300; } }
	}

	Behavior on opacity { Animation { duration: 300; } }
}
