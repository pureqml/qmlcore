Activity {
	id: mainWindow;
	property bool portraitOrientation: false;
	anchors.fill: renderer;
	name: "root";

	Item {
		id: safeArea;
		anchors.fill: mainWindow;
		anchors.margins: 20;
	}

	Protocol { id: protocol; enabled: true; }

	ProvidersModel { id: providersModel; protocol: protocol; }

	CategoriesModel	{
		id: categoriesModel;
		protocol: protocol;
		provider: providersModel.defaultProvider;
	}

	EPGModel { id: epgModel; protocol: protocol; }

	ColorTheme { id: colorTheme; }

	VideoPlayer {
		id: videoPlayer;
		anchors.fill: mainWindow;
		//source: lastChannel.source ? lastChannel.source : "http://msk3.peers.tv/streaming/friday/126/tvrec/playlist.m3u8";
		source: "http://msk3.peers.tv/streaming/friday/126/tvrec/playlist.m3u8";
		autoPlay: true;

		Preloader {
			anchors.centerIn: videoPlayer;
			visible: !videoPlayer.ready;
		}
	}

	//onBackPressed: {
		//if (infoPanel.visible) {
			//infoPanel.hide();
		//} else if (!osdLayout.show) {
			//viewsFinder.closeApp();
			//ondatraPlayer.abort();
		//}
	//}

	onSelectPressed: {
		if (!osdLayout.show) {
			infoPanel.hide();
			osdLayout.showUp();
		}
	}

	InfoPanel {
		id: infoPanel;
		anchors.left: safeArea.left;
		anchors.bottom: safeArea.bottom;
	}

	Item {
		id: osdLayout;
		property bool show: true;
		opacity: show ? 1.0 : 0.0;

		MainMenu {
			id: menu;

			onDownPressed: { channelsPanel.forceActiveFocus(); }
			onIsAlive: { displayTimer.restart(); }
		}

		ChannelsPanel {
			id: channelsPanel;
			anchors.top: menu.bottom;
			anchors.topMargin: 2;

			onUpPressed: {
				//if (panelContent.activeFocus)
					menu.forceActiveFocus();
			}

			onSwitched(channel): {
				log("Channel switched:", channel.text, "url:", channel.url)
				osdLayout.show = false
				//ondatraPlayer.url = channel.url
				//ondatraPlayer.play()
				infoPanel.setChannel(channel)
			}

			onIsAlive: { displayTimer.restart(); }
		}

		Item {
			anchors.fill: parent;
			effects.shadow.spread: 5;
			effects.shadow.color: "#000a";
			effects.shadow.blur: 6;
			anchors.fill: menu;
			opacity: menu.activeFocus ? 1.0 : 0.0;
		}

		showUp: {
			this.show = true;
			menu.forceActiveFocus();
			displayTimer.restart();
		}
	}

	Timer {
		id: displayTimer;
		interval: 10000;
		repeat: false;
		running: false;

		onTriggered: { osdLayout.show = false; }
	}

	onBackPressed: {
		if (osdLayout.show)
			osdLayout.show = false;
	}
}
