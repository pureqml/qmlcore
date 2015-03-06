Item {
	id: mainWindow;
	anchors.fill: renderer;
	anchors.leftMargin: 75;
	anchors.rightMargin: 75;
	anchors.bottomMargin: 40;
	anchors.topMargin: 42;

	InfoPanel {
		id: infoPanel;
		anchors.fill: parent;
	}

	onBluePressed: {
		infoPanel.start();
	}
}
