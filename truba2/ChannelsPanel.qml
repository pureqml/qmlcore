Item {
	ChannelsModel { id: channelsModel; }

	Item {
		id: currentCategory;
		width: parent.width / 2;
		anchors.left: parent.left;
		anchors.top: parent.top;
		anchors.topMargin: 10;

		Text {
			id: currentCategoryText;
			anchors.left: parent.left;
			anchors.right: listIcon.left;
			anchors.top: parent.top;
			anchors.leftMargin: 10;
			clip: true;
			color: colorTheme.textColor;
		}

		Image {
			id: listIcon;
			source: "res/list.png";
			anchors.right: parent.right;
			anchors.top: parent.top;
		}

		MouseArea {
			anchors.fill: listIcon;

			onClicked: {
				log("IMPL");
			}
		}
	}

	CategoriesList {
		id: categoriesList;
		anchors.right: parent.right;
		anchors.top: currentCategory.bottom;
		anchors.bottom: parent.bottom;

		onCountChanged: {
			if (this.count > 1 && !channels.count) {
				var cat = categoriesList.model.get(0);
				channelsModel.setList(cat.list);
				currentCategoryText.text = cat.text;
			}
		}

		updateList: {
			var cat = categoriesList.model.get(categoriesList.currentIndex);
			channelsModel.setList(cat.list);
			channels.contentX = 0;
			currentCategoryText.text = cat.text;
		}

		onSelectPressed:	{ this.updateList(); }
		onClicked:			{ this.updateList(); }
	}

	GridView {
		id: channels;
		model: channelsModel;
	}
}
