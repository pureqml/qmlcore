Item {
	id: channelsPanelProto;
	signal channelSwitched;
	signal focusPropagated;

	Rectangle {
		width: categoriesList.width;
		anchors.top: renderer.top;
		anchors.left: renderer.left;
		anchors.bottom: parent.bottom;
		color: colorTheme.backgroundColor;
		opacity: 0.3;
	}

	CategoriesList {
		id: categoriesList;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.bottom: parent.bottom;
		model: categoriesModel;
		spacing: 1;

		onCountChanged: {
			if (this.count > 1 && !channels.count)
				channelsModel.setList(categoriesList.model.get(0).list);
		}

		onRightPressed: {
			channels.currentIndex = 0;
			channels.forceActiveFocus();
		}

		onCurrentIndexChanged: { updateCategoryTimer.restart(); }
	}

	Timer {
		id: updateCategoryTimer;
		interval: 400;

		onTriggered: { channelsModel.setList(categoriesList.model.get(categoriesList.currentIndex).list); }
	}

	ChannelsModel { id: channelsModel; }

	ChannelsList {
		id: channels;
		anchors.top: categoriesList.top;
		anchors.left: categoriesList.right;
		anchors.right: videoPlayer.left;
		anchors.leftMargin: 10;
		anchors.rightMargin: 10;
		spacing: 1;
		model: channelsModel;

		switchTuCurrent:	{ channelsPanelProto.channelSwitched(this.model.get(this.currentIndex)); }
		onSelectPressed:	{ this.switchTuCurrent(); }
		onClicked:			{ this.switchTuCurrent(); }

		onRightPressed: {
			if ((this.currentIndex % this.columns) == (this.columns - 1))
				channelsPanelProto.focusPropagated();
			else
				this.currentIndex++;
		}

		onLeftPressed: {
			if (this.currentIndex % this.columns)
				this.currentIndex--;
			else
				categoriesList.forceActiveFocus();
		}
	}
}
