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

	LocalStorage {
		id: lastChannel;
		property string source;
		name: "lastChannel";

		onCompleted: {
			this.read();
			var channelInfo = lastChannel.value ? JSON.parse(lastChannel.value): {};
			if (channelInfo && channelInfo.url)
				channelInfo.program = {};
			else
				channelInfo = {
					"lcn":213,
					"genres":["Развлекательные"],
					"text":"Пятница +7",
					"provider":"zabavaSlyUkraine",
					"program": {},
					"color":"#ffffff",
					"url": "http://msk3.peers.tv/streaming/friday/126/tvrec/playlist.m3u8",
					"id":"пятница"
				};
			mainWindow.switchToChannel(channelInfo);
		}
	}

	VideoPlayer {
		id: videoPlayer;
		anchors.fill: renderer;
		source: lastChannel.source ? lastChannel.source : "http://msk3.peers.tv/streaming/friday/126/tvrec/playlist.m3u8";
		autoPlay: true;

		//Preloader {
			//anchors.centerIn: videoPlayer;
			//visible: !videoPlayer.ready;
		//}
	}

	MouseArea {
		anchors.fill: parent;
		hoverEnabled: true;

		onClicked: { mainWindow.showInfo(); }
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

				onSwitched(channel): { mainWindow.switchToChannel(channel) }
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

		WebButton {
			anchors.left: mainWindow.left;
			anchors.bottom: mainWindow.bottom;
			anchors.margins: 20;
			icon: "close.png";

			onClicked: {
				if (osdLayout.visible)
					osdLayout.hide()
			}
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

	InfoPanel {
		id: infoPanel;

		onMenuCalled: {
			this.hide();
			osdLayout.show();
		}
	}

	Spinner { visible: protocol.loading; }

	onRedPressed: {
		if (!osdLayout.visible) {
			infoPanel.hide()
			osdLayout.show()
		} else {
			osdLayout.hide()
		}
	}

	switchToChannel(channel): {
		if (!channel) {
			log("Try to switch to null channel.");
			return;
		}
		log("Channel switched:", channel.text, "url:", channel.url)
		lastChannel.value = JSON.stringify(channel);
		videoPlayer.source = channel.url
		this.channel = channel
	}

	showInfo: {
		if (osdLayout.visible)
			return false;
		else
			infoPanel.show(this.channel)
		return true;
	}

	onSelectPressed: {
		if (!this.showInfo())
			event.accepted = false;
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
