Activity {
	id: mainWindow;
	property bool portraitOrientation: false;
	property variant channel;
	anchors.fill: renderer;
	name: "root";

	PlatformInfo { id: globals; }

	Protocol {
		id: protocol;
		enabled: true;

		onLoadingChanged: {
			if (!this.loading)
				osdLayout.start()
		}
	}

	ProvidersModel {
		id: providersModel;
		protocol: protocol;
	}

	CategoriesModel	{
		id: categoriesModel;
		protocol: protocol;
		provider: providersModel.choosedProvider;
	}

	EPGModel { id: epgModel; protocol: protocol; }

	ColorTheme { id: colorTheme; }

	LocalStorage {
		id: lastChannel;
		property string url;
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
			videoPlayer.source = lastChannel.url ? lastChannel.url : "http://msk3.peers.tv/streaming/friday/126/tvrec/playlist.m3u8";
		}
	}

	VideoPlayer {
		id: videoPlayer;
		anchors.fill: renderer;
		autoPlay: true;

		//Preloader {
			//anchors.centerIn: videoPlayer;
			//visible: !videoPlayer.ready;
		//}
	}

	MouseArea {
		anchors.fill: parent;
		hoverEnabled: true;

		onClicked: { infoPanel.show(mainWindow.channel) }

		onHorizontalSwiped(event): {
			if (!mainWindow.hasAnyActiveChild)
				osdLayout.start()
		}
	}

	Activity {
		id: osdLayout;
		anchors.fill: parent;
		opacity: !active ? 0.0 : 1.0;
		name: "menu";

		PageStack {
			id: content;
			anchors.top: parent.top;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.bottom: parent.bottom;
			anchors.leftMargin: menu.minWidth + 2;
			currentIndex: menu.currentIndex;
			visible: osdLayout.active;

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
			visible: osdLayout.active;

			onRightPressed: { content.choose() }
		}

		WebButton {
			anchors.top: mainWindow.top;
			anchors.right: mainWindow.right;
			anchors.margins: 20;
			icon: "close.png";

			onClicked: {
				if (osdLayout.visible)
					osdLayout.stop()
			}
		}

		onActiveChanged: { if (this.active) menu.setFocus() }

		onStarted:		{ menu.setFocus(); }
	}

	InfoPanel {
		id: infoPanel;

		onMenuCalled: {
			this.stop();
			osdLayout.start();
		}
	}

	Spinner { visible: protocol.loading; }

	onUpPressed:	{ this.showInfo() }
	onDownPressed:	{ this.showInfo() }

	showInfo: {
		if (!this.hasAnyActiveChild)
			infoPanel.show(this.channel)
	}

	switchToChannel(channel): {
		if (!channel) {
			log("Try to switch to null channel.")
			return;
		}
		log("Channel switched:", channel.text, "url:", channel.url)
		lastChannel.value = JSON.stringify(channel)
		videoPlayer.source = channel.url
		this.channel = channel
		if (infoPanel.active)
			infoPanel.show(this.channel)
	}

	onSelectPressed: {
		if (!osdLayout.active)
			osdLayout.start()
	}

	onBackPressed: {
		if (osdLayout.active)
			return false

		// Crunch for compiler.
		if (!widgetAPI)
			var widgetAPI = { }
		if (globals.platform == "samsung")
			widgetAPI.sendExitEvent()
	}

	onRightPressed:			{ this.channelUp() }
	onChannelUpPressed:		{ this.channelUp() }
	onLeftPressed:			{ this.channelDown() }
	onChannelDownPressed:	{ this.channelDown() }

	channelUp: {
		if (!this.hasAnyActiveChild || infoPanel.active)
			watchPage.switchNextChannel()
	}

	channelDown: {
		if (!this.hasAnyActiveChild || infoPanel.active)
			watchPage.switchPreviousChannel()
	}
}
