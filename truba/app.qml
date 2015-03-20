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

	MainMenu {
		id: mainMenu;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.top: renderer.top;
		active: parent.hasAnyActiveChild || mainPageStack.activeFocus;
	 	z: 10;

		onDownPressed: { mainPageStack.forceActiveFocus(); }
		onOptionChoosed(idx): { mainPageStack.currentIndex = idx; }

		onCloseAll: {
			if (infoPanel.active)
				infoPanel.stop();
			else
				infoPanel.start();
		}
	}

	PageStack {
		id: mainPageStack;
		anchors.top: mainMenu.bottom;
		anchors.bottom: parent.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.topMargin: 1;
		visible: mainMenu.activeFocus || activeFocus;

		ChannelsPanel {
			id: channelsPanel;
			protocol: parent.protocol;

			onChannelSwitched(channel): {
				if (!channel) {
					log("App: Empty channel info.");
					return;
				}
				videoPlayer.source = channel.url;
				infoPanel.fillChannelInfo(channel);
			}
		}

		EPGPanel { id: epgPanel; }
		VODPanel { id: vodPanel; }
		SettingsPanel { }

		onUpPressed: { mainMenu.forceActiveFocus(); }
	}

	onRedPressed: {
		mainPageStack.currentIndex = 2;
		mainPageStack.forceActiveFocus();
	}

	onBluePressed: {
		infoPanel.start();
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
