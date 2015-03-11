Activity {
	id: mainWindow;
	anchors.fill: renderer;
	anchors.leftMargin: 75;
	anchors.rightMargin: 75;
	anchors.bottomMargin: 40;
	anchors.topMargin: 42;

	ColorTheme { id: colorTheme; }

	// MouseArea {
	// 	anchors.left: renderer.left;
	// 	anchors.top: renderer.top;
	// 	anchors.bottom: renderer.bottom;
	// 	width: 325;
	// 	hoverEnabled: !parent.hasAnyActiveChild || parent.currentActivity == "mainMenu";

	// 	onMouseXChanged: { 
	// 		if (this.hoverEnabled)
	// 			mainMenu.start();
	// 	}

	// 	onMouseYChanged: {
	// 		if (this.hoverEnabled) 
	// 			mainMenu.start();
	// 	}
	// }


	MouseArea {
		anchors.fill: renderer;
		hoverEnabled: !parent.hasAnyActiveChild || parent.currentActivity == "infoPanel";

		onMouseXChanged: { 
			if (this.hoverEnabled)
				infoPanel.start();
		}

		onMouseYChanged: {
			if (this.hoverEnabled) 
				infoPanel.start();
		}
	}

	MainMenu {
		id: mainMenu;
		anchors.left: parent.left;
		anchors.top: parent.top;
		anchors.bottom: parent.bottom;
		width: 250;
	}

	InfoPanel {
		id: infoPanel;
		anchors.fill: parent;
	}


	onBluePressed: {
		infoPanel.start();
	}
}
