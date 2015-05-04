Activity {
	id: mainWindow;
	property bool portraitOrientation: false;
	anchors.fill: renderer;
	name: "root";

	Protocol		{ id: protocol; enabled: true; }

	ColorTheme		{ id: colorTheme; }

	LocalStorage {
		id: lastChannel;
		property string source;
		name: "lastChannel";

		onCompleted: {
			this.read();
			var channelInfo = lastChannel.value ? JSON.parse(lastChannel.value): {};
			if (channelInfo)
				mainWindow.switchToChannel(channelInfo);
		}
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
		effects.blur: channelsPanel.active ? 3 : 0;

		VideoPlayer {
			id: videoPlayer;
			anchors.top: mainWindow.top;
			anchors.left: mainWindow.left;
			width: renderer.width;
			height: renderer.height;
			source: lastChannel.source ? lastChannel.source : "http://hlsstr04.svc.iptv.rt.ru/hls/CH_NICKELODEON/variant.m3u8?version=2";
			autoPlay: true;

			onHeightChanged: { mainWindow.updateLayout(); }
		}
	}

	Controls {
		id: controls;
		anchors.bottom:			videoPlayer.bottom;
		showListsButton:		!channelsPanel.active;
		protocol:				protocol;
		volume:					videoPlayer.volume;

		onFullscreenToggled:	{ renderer.fullscreen = true; }
		onListsToggled:			{ channelsPanel.start(); }
		onVolumeUpdated(value):	{ videoPlayer.volume = value; }
	}

	ChannelsPanel {
		id: channelsPanel;
		anchors.topMargin: parent.portraitOrientation ? parent.height / 2 : 0;
		protocol: parent.protocol;

		onChannelSwitched(channel): { mainWindow.switchToChannel(channel); }
	}

	updateLayout: {
		if (renderer.width < renderer.height) {
			log("Layout: w:" + renderer.width + "x" + renderer.height + ". Use portrait orientation.");
			this.portraitOrientation = true;
		} else {
			log("Layout: w:" + renderer.width + "x" + renderer.height + ". Use usual orientation.");
			this.portraitOrientation = false;
		}
	}

	setProgramInfo(program): { controls.setProgramInfo(program); }

	switchToChannel(channel): {
		if (!channel) {
			log("App: Empty channel info.");
			return;
		}
		lastChannel.value = JSON.stringify(channel);
		videoPlayer.source = channel.url;
		controls.setChannelInfo(channel);

		if (!epgModel.protocol)
			return;

		var self = this;
		var channelName = channel.text;
		var program = epgModel.protocol.getCurrentPrograms(function(programs){
			for (var i in programs) {
				if (channelName == programs[i].channel) {
					self.setProgramInfo(programs[i]);
					break;
				}
			}
		});
	}

	onCompleted: { this.updateLayout(); }
}
