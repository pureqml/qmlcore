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
		hoverEnabled: !parent.hasAnyActiveChild || parent.currentActivity == "infoPanel";

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

		onMenuCalled: { mainMenu.start(); }
	}

	MainMenu {
		id: mainMenu;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.top: renderer.top;
		active: infoPanel.active || mainPageStack.activeFocus;
	 	z: 10;

		onDownPressed: { mainPageStack.forceActiveFocus(); }
		onOptionChoosed(idx): {
			if (idx !== mainPageStack.currentIndex || !mainPageStack.active) {
				mainPageStack.active = true;
				mainPageStack.currentIndex = idx;
			}
			else {
				mainPageStack.active = false;
			}
		}

		onSearchRequest(request): {
			this.active = false;
			infoPanel.active = false;
			searchPanel.start();
			searchPanel.searchRequest = request;
			searchPanel.search();
		}

		onCloseAll: { 
			infoPanel.active = !infoPanel.active; 
			mainPageStack.active = false;
		}
	}

	PageStack {
		id: mainPageStack;
		anchors.top: mainMenu.bottom;
		anchors.bottom: parent.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.topMargin: 1;
		property bool active: false;
		opacity: active ? 1 : 0;
//		visible: mainMenu.active && (mainMenu.activeFocus || activeFocus);

		ChannelsPanel {
			id: channelsPanel;
			protocol: parent.protocol;

			onChannelSwitched(channel): { mainWindow.switchToChannel(channel); }
		}

		EPGPanel { id: epgPanel; }
		VODPanel { id: vodPanel; }
		SettingsPanel { }

		onUpPressed: { mainMenu.forceActiveFocus(); }
	}

	SearchPanel {
		id: searchPanel;
		protocol: parent.protocol;

		onChannelSwitched(channel): { mainWindow.switchToChannel(channel); }
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

	onRedPressed: {
		mainPageStack.currentIndex = 2;
		mainPageStack.forceActiveFocus();
	}

	onBluePressed: {
		infoPanel.active = true;
	}

	onGreenPressed: {
		mainPageStack.currentIndex = 0;
		mainPageStack.forceActiveFocus();
	}

	onYellowPressed: {
		mainPageStack.currentIndex = 1;
		mainPageStack.forceActiveFocus();
	}
}
