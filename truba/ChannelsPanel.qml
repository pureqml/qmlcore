Activity {
	id: channelsPanelProto;
	signal channelSwitched;
	width: categoriesList.width + channels.width;
	anchors.top: renderer.top;
	anchors.left: renderer.left;
	anchors.bottom: renderer.bottom;
	opacity: active ? 1.0 : 0.0;

	ChannelsModel { id: channelsModel; }

	Rectangle {
		width: categoriesList.width;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.bottom: parent.bottom;
		color: colorTheme.backgroundColor;

		Image {
			id: trubaLogo;
			anchors.left: parent.left;
			anchors.top: parent.top;
			anchors.topMargin: 31;
			anchors.leftMargin: 27;
			source: "res/logo.png";
		}

		Rectangle {
			id: channelsPanelSectionLine;
			height: 1;
			anchors.top: trubaLogo.bottom;
			anchors.topMargin: 31;
			width: categoriesList.width;
			color: colorTheme.activeBackgroundColor;
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
	}

	Rectangle {
		anchors.top: renderer.top;
		anchors.left: categoriesList.right;
		anchors.right: channels.right;
		anchors.bottom: renderer.bottom;
		anchors.rightMargin: -20;
		color: "#000";
		opacity: 0.5;
	}

	Item {
		width: channels.width;
		height: channels.height;
		anchors.top: categoriesList.top;
		anchors.left: categoriesList.right;
		clip: true;

		ChannelsList {
			id: channels;
			anchors.top: parent.top;
			anchors.left: parent.left;
			model: channelsModel;

			onSelectPressed:	{ this.switchTuCurrent(); }
			onClicked:			{ this.switchTuCurrent(); }

			switchTuCurrent: {
				var channel = this.model.get(this.currentIndex);
				channelInfo.fillInfo(channel);
				channelsPanelProto.channelSwitched(channel);
			}
		}
	}

	ChannelInfo {
		id: channelInfo;
		anchors.top: channels.bottom;
		anchors.left: categoriesList.right;
		anchors.bottom: parent.bottom;
		anchors.right: channels.right;
	
		onUpPressed: { channels.forceActiveFocus(); }
	}

	MouseArea {
		anchors.left: channels.right;
		anchors.right: renderer.right;
		anchors.top: parent.top;
		anchors.bottom: parent.bottom;
		hoverEnabled: parent.active;

		onClicked: { channelsPanelProto.stop(); }
	}

	Timer {
		id: updateCategoryTimer;
		interval: 400;

		onTriggered: { channelsModel.setList(categoriesList.model.get(categoriesList.currentIndex).list); }
	}

	Behavior on opacity { Animation { duration: 250; } }
}
