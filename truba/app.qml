Activity {
	id: mainWindow;
	anchors.fill: renderer;
	anchors.leftMargin: 75;
	anchors.rightMargin: 75;
	anchors.bottomMargin: 40;
	anchors.topMargin: 42;

	ColorTheme { id: colorTheme; }
	Protocol { id: protocol; enabled: true; }

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


	InfoPanel {
		id: infoPanel;
		anchors.fill: parent;

		onMenuCalled: {
			mainMenu.start();
		}
	}

	MainMenu {
		id: mainMenu;
		anchors.left: parent.left;
		anchors.top: parent.top;
		anchors.bottom: parent.bottom;

		onOptionChoosed(option): {
			if (option === "epg")
				epgPanel.start();
			else if (option === "channelList")
				channelsPanel.start();
			else if (option === "movies")
				vodPanel.start();
			// else if (option === "settings")
			// 	settings.start();
		}
	}

	ChannelsPanel { id: channalsPanel; protocol: parent.protocol; }
	EPGPanel { id: epgPanel; }
	VODPanel { id: vodPanel; }

	onRedPressed: { vodPanel.start(); }
	onBluePressed: { infoPanel.start(); }
	onGreenPressed: { channalsPanel.start(); }
	onYellowPressed: { epgPanel.start(); }
}
