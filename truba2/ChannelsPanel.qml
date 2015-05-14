Item {
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
			anchors.fill: listIcon;

			onClicked: { categoriesList.toggle(); }
		}
	}

	ChannelsList {
		id: channels;
		anchors.top: currentCategory.bottom;
		anchors.bottom: parent.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.topMargin: 10;
	}

	Rectangle {
		opacity: categoriesList.active ? 1.0 : 0.0;
		anchors.left: categoriesList.right;
		anchors.top: categoriesList.top;
		width: 40;
		height: categoriesList.height;
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
}
