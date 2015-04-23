Activity {
	id: mainWindow;
	anchors.fill: renderer;
	name: "root";

	Protocol		{ id: protocol; enabled: true; }

	ColorTheme		{ id: colorTheme; }

	LocalStorage {
		id: lastChannel;
		name: "lastChannel";

		onCompleted: { this.read(); }
	}

	ProvidersModel {
		id: providersModel;
		protocol: protocol;
	}

	CategoriesModel	{
		id: categoriesModel;
		protocol: protocol;
		providers: providersModel.providers;
	}

	EPGModel {
		id: epgModel;
		protocol: protocol;
	}

	Timer {
		id: updateTimer;
		interval: 24 * 3600 * 1000;
		repeat: true;

		onTriggered: {
			categoriesModel.update();
			epgModel.update();
		}
	}

	Item {
		effects.blur: channelsPanel.active ? 10 : 0;

		VideoPlayer {
			id: videoPlayer;
			anchors.fill: renderer;
			source: lastChannel.value ? lastChannel.value : "http://hlsstr04.svc.iptv.rt.ru/hls/CH_NICKELODEON/variant.m3u8?version=2";
			autoPlay: true;
		}
	}

	Controls {
		showListsButton:		!channelsPanel.active;
		volume:					videoPlayer.volume;

		onFullscreenToggled:	{ renderer.fullscreen = true; }
		onListsToggled:			{ channelsPanel.start(); }
		onVolumeUpdated:		{ videoPlayer.volume = this.value; }
	}

	ChannelsPanel {
		id: channelsPanel;
		protocol: parent.protocol;

		onChannelSwitched(channel): { mainWindow.switchToChannel(channel); }
	}

	switchToChannel(channel): {
		if (!channel) {
			log("App: Empty channel info.");
			return;
		}
		lastChannel.value = channel.url;
		videoPlayer.source = channel.url;
	}
}
