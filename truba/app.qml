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

	Protocol		{ id: protocol; enabled: true; }
	ColorTheme		{ id: colorTheme; }

	ProvidersModel {
		id: providersModel;
		protocol: protocol;
	}

	EPGModel {
		id: epgModel;
		protocol: protocol;
	}

	CategoriesModel {
		id: categoriesModel;
		protocol: protocol;
		providers: providersModel.providers;
	}

	Timer {
		id: updateTimer;
		interval: 24 * 3600 * 1000;
		repeat: true;

		updateImpl: {
			categoriesModel.update();
			epgModel.update();
		}

		onTriggered: { this.updateImpl(); }
	}

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

	Item {
		id: activityArea;
		anchors.top: topMenu.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.bottom: infoPanel.top;
		anchors.topMargin: 2;
		anchors.leftMargin: 101;
	}

	ChannelsPanel {
		id: channelsPanel;
		protocol: parent.protocol;
		anchors.fill: activityArea;

		onChannelSwitched(channel): { mainWindow.switchToChannel(channel); }
		onLeftPressed:	{ mainMenu.forceActiveFocus(); }
		onUpPressed:	{ mainMenu.forceActiveFocus(); }
	}

	EPGPanel {
		id: epgPanel;
		anchors.fill: activityArea;

		onChannelSwitched(channel): { mainWindow.switchToChannel(channel); }
		onLeftPressed:	{ mainMenu.forceActiveFocus(); }
		onUpPressed:	{ topMenu.forceActiveFocus(); }
	}

	VODPanel {
		id: vodPanel;
		anchors.fill: activityArea;

		onLeftPressed:	{ mainMenu.forceActiveFocus(); }
		onUpPressed:	{ topMenu.forceActiveFocus(); }
	}

	SettingsPanel {
		id: settings;
		anchors.fill: activityArea;
		protocol: parent.protocol;

		onLeftPressed:	{ mainMenu.forceActiveFocus(); }
		onUpPressed:	{ topMenu.forceActiveFocus(); }

		onActiveChanged: {
			if (!this.active)
				updateTimer.updateImpl();
		}
	}

	SearchPanel {
		id: searchPanel;
		protocol: parent.protocol;
		anchors.fill: activityArea;

		onChannelSwitched(channel): { mainWindow.switchToChannel(channel); }
		onUpPressed: { topMenu.forceActiveFocus(); }
	}

	TopMenu {
		id: topMenu;
		active: mainMenu.active;

		onSearchRequest(request): {
			infoPanel.active = false;
			searchPanel.start();
			searchPanel.searchRequest = request;
			searchPanel.search();
		}

		onCloseAll: {
			infoPanel.active = !infoPanel.active;
			mainWindow.closeAll();
		}

		onDownPressed: {
			if (mainMenu.active)
				mainMenu.forceActiveFocus();
		}
	}

	MainMenu {
		id: mainMenu;
		anchors.left: renderer.left;
		anchors.top: topMenu.bottom;
		anchors.topMargin: 2;
		active: infoPanel.active || parent.hasAnyActiveChild;
		z: 100500;

		onRightPressed: {
			if (channelsPanel.active)
				channelsPanel.forceActiveFocus();
			else if (epgPanel.active)
				epgPanel.forceActiveFocus();
			else if (vodPanel.active)
				vodPanel.forceActiveFocus();
			else if (settings.active)
				settings.forceActiveFocus();
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

		onUpPressed: {
			if (this.currentIndex <= 0)
				topMenu.forceActiveFocus();
			else
				this.currentIndex--;
		}

		onDownPressed: {
			if (this.currentIndex >= this.count - 1) {
				infoPanel.active = true;
				infoPanel.forceActiveFocus();
			} else {
				this.currentIndex++;
			}
		}
	}

	MuteIcon { mute: videoPlayer.volume <= 0; }

	InfoPanel {
		id: infoPanel;
		height: 200;
		anchors.bottom: parent.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;
		protocol: parent.protocol;
		volume: videoPlayer.volume;

		onMenuCalled:		{ mainMenu.start(); }
		onVolumeUpdated(v):	{ videoPlayer.volume = v; }

		onUpPressed: {
			if (mainMenu.active)
				mainMenu.forceActiveFocus();
		}
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

	onBackPressed: {
		if (!infoPanel.active && !mainMenu.active && !mainWindow.hasAnyActiveChild) {
			event.accepted = false;
			return true;
		}
		if (mainWindow.hasAnyActiveChild)
			mainWindow.closeAll();
		if (infoPanel.active)
			infoPanel.active = false;
		if (mainMenu.active)
			mainMenu.active = false;
	}

	onMenuPressed: {
		if (mainMenu.active) {
			mainMenu.active = false;
		} else {
			mainMenu.active = true;
			mainMenu.forceActiveFocus();
		}
	}
}
