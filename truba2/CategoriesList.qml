Item {
	id: categoriesList;
	signal genreChoosed;
	property string prevGenre: "";
	property int count: categoriesListView.count;
	width: renderer.width / 4.2;
	anchors.top: parent.top;
	anchors.left: parent.left;
	anchors.bottom: parent.bottom;

	Background { }

	TrubaListView {
		id: categoriesListView;
		anchors.fill: parent;
		model: categoriesModel;
		delegate: CategoryDelegate { }

		onToggled: {
			updateTimer.requestIndex = categoriesListView.currentIndex
			updateTimer.process()
		}

		onCurrentIndexChanged: { categoriesList.updateContent() }
	}

	Timer {
		id: updateTimer;
		property int requestIndex: 0;
		interval: 1000;
		repeat: false;

		process: {
			this.stop()

			if (this.requestIndex != categoriesListView.currentIndex)
				this.restart()

			var idx = categoriesListView.currentIndex
			categoriesList.genreChoosed(categoriesListView.model.get(idx).list)
			categoriesList.prevGenre = categoriesListView.model.get(idx).text
		}

		onTriggered: { this.process() }
	}

	updateContent: {
		updateTimer.requestIndex = categoriesListView.currentIndex
		updateTimer.restart()
	}

	onActiveFocusChanged: {
		var genre = categoriesListView.model.get(categoriesListView.currentIndex).text
		if (this.activeFocus && genre != this.prevGenre)
			this.updateContent()
	}

	Behavior on width { Animation { duration: 300; } }
}
