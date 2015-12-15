Activity {
	id: mainWindow;
	property bool portraitOrientation: false;
	property variant channel;
	anchors.fill: renderer;
	name: "root";

	Protocol {
		id: protocol;
		enabled: true;

		onLoadingChanged: { if (this.loading) menu.setFocus() }
	}

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
		anchors.fill: renderer;
		source: "http://msk3.peers.tv/streaming/friday/126/tvrec/playlist.m3u8";
		autoPlay: true;

		//Preloader {
			//anchors.centerIn: videoPlayer;
			//visible: !videoPlayer.ready;
		//}
	}

	Item {
		id: osdLayout;
		anchors.fill: parent;
		opacity: protocol.loading ? 0.0 : 1.0;

		PageStack {
			id: content;
			anchors.top: parent.top;
			anchors.left: menu.right;
			anchors.right: parent.right;
			anchors.bottom: parent.bottom;
			anchors.leftMargin: 2;
			currentIndex: menu.currentIndex;

			WatchPage {
				id: watchPage;
				onSwitched(channel): {
					log("Channel switched:", channel.text, "url:", channel.url)
					videoPlayer.source = channel.url
					mainWindow.channel = channel
				}
			}

			SettingsPage { id: settingsPage; }

			//TODO: fix it
			choose: {
				if (this.currentIndex == 0)
					watchPage.setFocus()
				else
					settingsPage.setFocus()
			}

			onLeftPressed: { menu.setFocus() }
		}

		MainMenu {
			id: menu;

			onRightPressed: { content.choose() }
		}
	
		hide: {
			this.visible = false
			watchPage.reset()
		}

		show: {
			this.visible = true
			menu.setFocus()
		}

		onBackPressed: { osdLayout.hide() }
	}

	InfoPanel { id: infoPanel; }

	Spinner { visible: protocol.loading; }

	onRedPressed: {
		infoPanel.hide()
		osdLayout.show()
	}

	onSelectPressed: {
		if (osdLayout.visible)
			event.accepted = false;
		else
			infoPanel.show(this.channel)
	}

	onBackPressed: {
		if (osdLayout.visible)
			return false

		// Crunch for compiler.
		if (!widgetAPI)
			var widgetAPI = { }
		if (_globals.core.vendor == "samsung")
			widgetAPI.sendExitEvent()
	}
}
