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
		anchors.top: renderer.top;
		anchors.topMargin: (50 - listIcon.height) / 2;
		anchors.leftMargin: 10;

		Image {
			id: listIcon;
			source: "res/list.png";
			anchors.left: parent.left;
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
		dragEnabled: !parent.parent.hasAnyActiveChild;

		onClicked:				{ if (this.hoverEnabled) this.switchToCurrent(); }
		onSelectPressed:		{ this.switchToCurrent(); }
		onCurrentIndexChanged:	{ epgpanel.hide(); }

		onContentYChanged: {
			if (epgpanel.visible)
				epgpanel.y = this.getCurrentDelegateY() - 70;
		}

		onDetailsRequest: {
			if (epgpanel.visible) {
				epgpanel.hide();
			} else {
				epgpanel.x = this.getCurrentDelegateX() + 10;

				var a = epgpanel.getAnimation('y')
				if (a)
					a.disable()
				epgpanel.y = this.getCurrentDelegateY() - 70;
				if (a)
					a.enable()

				epgpanel.show(this.model.get(this.currentIndex));
			}
		}

		switchToCurrent: {
			if (categoriesList.active)
				categoriesList.toggle();

			var channel = this.model.get(this.currentIndex);

			channel["categoryIndex"] = categoriesList.currentIndex;
			channelsPanelProto.channelSwitched(channel);
		}
	}

	Item {
		anchors.top: channels.top;
		anchors.bottom: channels.bottom;
		anchors.left: renderer.left;
		anchors.right: channels.right;
		anchors.rightMargni: 20;
		clip: true;

		EPGPanel {
			id: epgpanel;
			width: channels.width / 3;
			height: channels.height / 2;

			onProgramSelected(program): { channelsPanelProto.programSelected(program); }

			Behavior on y { Animation { duration: 300; } }
		}
	}

	Shadow {
		active: categoriesList.active;
		anchors.left: categoriesList.right;
		anchors.top: renderer.top;
		anchors.bottom: renderer.bottom;
	}

	CategoriesList {
		id: categoriesList;
		anchors.left: renderer.left;
		anchors.top: currentCategory.bottom;
		anchors.bottom: renderer.bottom;

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
			channels.contentY = 0;
			currentCategoryText.text = cat.text;
			this.toggle();
		}

		onCurrentIndexChanged:	{ epgpanel.hide(); }
		onSelectPressed:		{ this.updateList(); }
		onClicked:				{ this.updateList(); }
	}

	setCategoryIndex(idx): { categoriesList.currentIndex = idx; }
}
