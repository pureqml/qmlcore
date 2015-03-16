Activity {
	id: mainWindow;
	anchors.fill: renderer;
	// anchors.leftMargin: 75;
	// anchors.rightMargin: 75;
	// anchors.bottomMargin: 40;
	anchors.topMargin: 70;

	VideoPlayer {
		id: videoPlayer;
		anchors.fill: renderer;
		source: "http://hlsstr04.svc.iptv.rt.ru/hls/CH_NICKELODEON/variant.m3u8?version=2";
		autoPlay: true;
	}

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

		onMenuCalled: { mainMenu.start(); }
	}

	ChannelsPanel {
		id: channelsPanel;
		protocol: parent.protocol;

		onChannelSwitched(url): { videoPlayer.source = url; }
	}

	EPGPanel { id: epgPanel; }
	VODPanel { id: vodPanel; }

	MainMenu {
		id: mainMenu;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.top: renderer.top;
	 	active: parent.hasAnyActiveChild;

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

		onCloseAll: {
			if (infoPanel.active)
				infoPanel.stop();
			else
				infoPanel.start();
		}
	}

	onRedPressed: { vodPanel.start(); }
	onBluePressed: { infoPanel.start(); }
	onGreenPressed: { channelsPanel.start(); }
	onYellowPressed: { epgPanel.start(); }
}
