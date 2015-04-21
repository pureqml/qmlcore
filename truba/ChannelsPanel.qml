Activity {
	id: channelsPanelProto;
	signal channelSwitched;
	signal focusPropagated;
	opacity: active ? 1.0 : 0.0;
	width: categoriesList.width + channels.width;

	Rectangle {
		anchors.top: renderer.top;
		anchors.left: categoriesList.left;
		anchors.right: channels.right;
		anchors.bottom: renderer.bottom;
		color: "#000";
		opacity: 0.5;
	}

	Rectangle {
		width: categoriesList.width;
		anchors.top: renderer.top;
		anchors.left: renderer.left;
		anchors.bottom: parent.bottom;
		color: colorTheme.backgroundColor;

		Text {
			id: channelsPanelCaption;
			anchors.left: parent.left;
			anchors.top: parent.top;
			anchors.margins: 10;
			text: "TRUBA";
			font.pointSize: 32;
			color: colorTheme.accentTextColor;
		}

		Text {
			anchors.top: channelsPanelCaption.top;
			anchors.left: parent.left;
			anchors.leftMargin: channelsPanelCaption.paintedWidth + 10;
			text: "TV";
			font.pointSize: 32;
			color: colorTheme.textColor;
		}

		Rectangle {
			id: channelsPanelSectionLine;
			anchors.top: channelsPanelCaption.bottom;
			height: 1;
			width: categoriesList.width;
			color: colorTheme.activeBackgroundColor;
		}
	}

	CategoriesList {
		id: categoriesList;
		anchors.top: channelsPanelSectionLine.bottom;
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

	Item {
		height: renderer.height / 2 - channelsPanelCaption.paintedHeight;
		anchors.top: categoriesList.top;
		anchors.left: renderer.left;
		anchors.right: renderer.right;
		clip: true;

		ChannelsList {
			id: channels;
			anchors.top: categoriesList.top;
			anchors.left: categoriesList.right;
			anchors.leftMargin: 10;
			anchors.rightMargin: 10;
			spacing: 1;
			model: channelsModel;

			switchTuCurrent:	{ channelsPanelProto.channelSwitched(this.model.get(this.currentIndex)); }
			onSelectPressed:	{ this.switchTuCurrent(); }
			onClicked:			{ this.switchTuCurrent(); }

			//onRightPressed: {
				//if ((this.currentIndex % this.columns) == (this.columns - 1))
					//channelsPanelProto.focusPropagated();
				//else
					//this.currentIndex++;
			//}

			onLeftPressed: {
				if (this.currentIndex % this.columns)
					this.currentIndex--;
				else
					categoriesList.forceActiveFocus();
			}
		}
	}

	Behavior on opacity { Animation { duration: 250; } }
}
