Activity {
	id: mainWindow;
	anchors.fill: renderer;
	anchors.topMargin: 70;
	name: "root";

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
		hoverEnabled: !parent.hasAnyActiveChild;

		onMouseXChanged: { 
			if (this.hoverEnabled)
				infoPanel.active = true;
		}

		onMouseYChanged: {
			if (this.hoverEnabled) 
				infoPanel.active = true;
		}
	}

	InfoPanel {
		id: infoPanel;
		anchors.fill: parent;

		onMenuCalled:		{ mainMenu.start(); }
		onVolumeDecreased:	{ videoPlayer.volumeDown(); }
		onVolumeIncreased:	{ videoPlayer.volumeUp(); }
	}

	MainMenu {
		id: mainMenu;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.top: renderer.top;
		active: infoPanel.active || parent.hasAnyActiveChild;
	 	z: 10;

		onDownPressed: {
			if (channelsPanel.active)
				channelsPanel.forceActiveFocus();
			else if (epgPanel.active)
				epgPanel.forceActiveFocus();
			else if (vodPanel.active)
				vodPanel.forceActiveFocus();
			else if (settings.active)
				settings.forceActiveFocus();
			else
				infoPanel.forceActiveFocus();
		}

		onOptionChoosed(idx): {
			if (idx == 0)
				channelsPanel.start();
			else if (idx == 1)
				epgPanel.start();
			else if (idx == 2)
				vodPanel.start();
			else if (idx == 3)
				settings.start();
		}

		onSearchRequest(request): {
			this.active = false;
			infoPanel.active = false;
			searchPanel.start();
			searchPanel.searchRequest = request;
			searchPanel.search();
		}

		onCloseAll: { infoPanel.active = !infoPanel.active; }
	}

	Item {
		id: activityArea;
		anchors.top: mainMenu.bottom;
		anchors.bottom: infoPanel.top;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.topMargin: 1;
	}

	ChannelsPanel {
		id: channelsPanel;
		protocol: parent.protocol;
		anchors.fill: activityArea;

		onChannelSwitched(channel): { mainWindow.switchToChannel(channel); }
		onUpPressed: { mainMenu.forceActiveFocus(); }
	}

	EPGPanel {
		id: epgPanel;
		anchors.fill: activityArea;

		onUpPressed: { mainMenu.forceActiveFocus(); }
	}

	VODPanel {
		id: vodPanel;
		anchors.fill: activityArea;

		onUpPressed: { mainMenu.forceActiveFocus(); }
	}

	SettingsPanel {
		id: settings;
		anchors.fill: activityArea;

		onUpPressed: { mainMenu.forceActiveFocus(); }
	}

	SearchPanel {
		id: searchPanel;
		protocol: parent.protocol;
		anchors.fill: activityArea;

		onChannelSwitched(channel): { mainWindow.switchToChannel(channel); }
		onUpPressed: { mainMenu.forceActiveFocus(); }
	}

	switchToChannel(channel): {
		if (!channel) {
			log("App: Empty channel info.");
			return;
		}
		videoPlayer.source = channel.url;
		infoPanel.fillChannelInfo(channel);
		infoPanel.active = true;
	}

	onUpPressed:		{ videoPlayer.volumeUp(); }
	onDownPressed:		{ videoPlayer.volumeDown(); }
	onRedPressed:		{ vodPanel.start(); }
	onBluePressed:		{ infoPanel.active = true; }
	onGreenPressed:		{ channelsPanel.start(); }
	onYellowPressed:	{ epgPanel.start(); }
}
