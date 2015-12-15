Item {
	width: renderer.width * 0.4;
	anchors.top: parent.top;
	anchors.left: parent.left;
	anchors.bottom: parent.bottom;

	Background { }

	ListView {
		id: categoriesListView;
		anchors.fill: parent;
		positionMode: ListView.Center;
		keyNavigationWraps: false;
		model: providersModel;
		delegate: ProviderDelegate { }
	}
}
