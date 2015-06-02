Item {
	id: channelsPanelProto;
	signal channelSwitched;
	signal programSelected;
	property int spacing: 0;

	ChannelsModel {
		id: channelsModel;
		protocol: protocol;
	}

	Item {
		id: currentCategory;
		width: parent.width / 2;
		height: currentCategoryText.height;
		anchors.left: parent.left;
		anchors.top: parent.top;
		anchors.topMargin: 10;
		anchors.leftMargin: 10;

		Image {
			id: listIcon;
			source: "res/list.png";
			anchors.left: parent.left;
			anchors.top: parent.top;
		}

		Text {
			id: currentCategoryText;
			anchors.right: parent.right;
			anchors.left: listIcon.right;
			anchors.verticalCenter: listIcon.verticalCenter;
			anchors.leftMargin: 10;
			clip: true;
			font.pointSize: 18;
			color: colorTheme.textColor;
		}

		MouseArea {
			anchors.fill: parent;

			onClicked: { categoriesList.toggle(); }
		}
	}

	ChannelsList {
		id: channels;
		anchors.top: currentCategory.bottom;
		anchors.bottom: parent.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.topMargin: 10 + parent.spacing;

		onClicked:				{ this.switchToCurrent(); }
		onSelectPressed:		{ this.switchToCurrent(); }
		onCurrentIndexChanged:	{ epgpanel.hide(); }

		onDetailsRequest: {
			epgpanel.x = this.getCurrentDelegateX();
			epgpanel.y = this.getCurrentDelegateY() - 20;
			if (epgpanel.visible)
				epgpanel.hide();
			else
				epgpanel.show(this.model.get(this.currentIndex));
		}

		switchToCurrent: {
			if (categoriesList.active)
				categoriesList.toggle();

			var channel = this.model.get(this.currentIndex);

			channel["categoryIndex"] = categoriesList.currentIndex;
			channelsPanelProto.channelSwitched(channel);
		}
	}

	EPGPanel {
		id: epgpanel;
		width: parent.width / 3;
		height: parent.height / 2;

		onProgramSelected(program): { channelsPanelProto.programSelected(program); }
	}

	Rectangle {
		opacity: categoriesList.active ? 1.0 : 0.0;
		anchors.left: categoriesList.right;
		anchors.top: parent.top;
		anchors.bottom: parent.bottom;
		width: 30;
		gradient: Gradient {
			orientation: 1;

			GradientStop { color: "#0006"; position: 0; }
			GradientStop { color: "#0000"; position: 1; }
		}

		Behavior on opacity { Animation { duration: 300; } }
	}

	CategoriesList {
		id: categoriesList;
		anchors.left: parent.left;
		anchors.top: currentCategory.bottom;
		anchors.bottom: parent.bottom;

		onCountChanged: {
			if (this.count == this.currentIndex + 1 && !channels.count) {
				var cat = categoriesList.model.get(categoriesList.currentIndex);
				channelsModel.setList(cat.list);
				currentCategoryText.text = cat.text;
			}
			if (!this.count)
				channelsModel.setList("");
		}

		updateList: {
			var cat = categoriesList.model.get(categoriesList.currentIndex);
			channelsModel.setList(cat.list);
			channels.contentX = 0;
			currentCategoryText.text = cat.text;
			this.toggle();
		}

		onCurrentIndexChanged:	{ epgpanel.hide(); }
		onSelectPressed:		{ this.updateList(); }
		onClicked:				{ this.updateList(); }
	}

	setCategoryIndex(idx): { categoriesList.currentIndex = idx; }
}
