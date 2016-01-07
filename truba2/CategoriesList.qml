Item {
	id: categoriesList;
	signal genreChoosed;
	property bool active: true;
	property string prevGenre: "";
	property int count: categoriesListView.count;
	width: active ? renderer.width / 4.2 : 80;
	anchors.top: parent.top;
	anchors.left: parent.left;
	anchors.bottom: parent.bottom;

	Background { opacity: parent.activeFocus || innerCategoriesArea.containsMouse ? 1.0 : 0.8; }

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

	Image {
		anchors.centerIn: parent;
		source: colorTheme.res + "more.png";
		visible: !categoriesList.active;
	}

	MouseArea {
		id: innerCategoriesArea;
		anchors.fill: parent;
		hoverEnabled: true;
		visible: !categoriesList.active;

		onClicked: { categoriesList.active = true }
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
