Item {
	id: categoriesList;
	property string prevGenre: "";
	signal genreChoosed;
	width: 300;
	anchors.top: parent.top;
	anchors.left: parent.left;
	anchors.bottom: parent.bottom;

	Rectangle {
		anchors.fill: parent;
		color: colorTheme.focusablePanelColor;
	}

	ListView {
		id: categoriesListView;
		anchors.fill: parent;
		positionMode: ListView.Center;
		keyNavigationWraps: false;
		model: categoriesModel;
		delegate: CategoryDelegate { }

		onCurrentIndexChanged: { updateTimer.restart(); }
	}

	Timer {
		id: updateTimer;
		interval: 800;
		repeat: false;

		onTriggered: {
			categoriesList.genreChoosed(categoriesListView.model.get(categoriesListView.currentIndex).list)
			categoriesList.prevGenre = categoriesListView.model.get(categoriesListView.currentIndex).text
		}
	}

	onActiveFocusChanged: {
		var genre = categoriesListView.model.get(categoriesListView.currentIndex).text
		if (this.activeFocus && genre != this.prevGenre)
			updateTimer.restart()
	}
}
