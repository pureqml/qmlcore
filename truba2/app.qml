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

	//onRedPressed: {
		//if (!osdLayout.show) {
			//infoPanel.hide();
			//osdLayout.showUp();
		//}
	//}

	//onBackPressed: {
		//if (infoPanel.visible) {
			//infoPanel.hide();
		//} else if (!osdLayout.show) {
			//viewsFinder.closeApp();
			//ondatraPlayer.abort();
		//}
	//}

	//onSelectPressed: {
		//if (osdLayout.show)
			//return false;
		//if (infoPanel.visible)
			//infoPanel.hide()
		//else
			//infoPanel.show()
	//}

	//InfoPanel {
		//id: infoPanel;
		//anchors.left: safeArea.left;
		//anchors.bottom: safeArea.bottom;
	//}


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

			onSwitched: {
				log("Channel switched:", channel.text, "url:", channel.url)
				osdLayout.show = false
				//ondatraPlayer.url = channel.url
				//ondatraPlayer.play()
				infoPanel.setChannel(channel)
			}

			onIsAlive: { displayTimer.restart(); }
		}

		//BorderShadow3D {
			//anchors.fill: menu;
			//opacity: menu.activeFocus ? 1.0 : 0.0;

			//Behavior on opacity { animation: Animation {  duration: 300; } }
		//}

		//showUp: {
			//this.show = true;
			//menu.forceActiveFocus();
			//displayTimer.restart();
		//}
	}

	Timer {
		id: displayTimer;
		interval: 7000;
		repeat: false;
		running: false;

		onTriggered: { osdLayout.show = false; }
	}

	//onBackPressed: {
		//if (osdLayout.show)
			//osdLayout.show = false;
	//}

	//onStarted: {
		//osdLayout.showUp();
		//providersModel.update();
		//ondatraPlayer.play();
	//}
}
