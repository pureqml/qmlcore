Activity {
	id: mainWindow;
	property bool portraitOrientation: false;
	anchors.left: renderer.left;
	anchors.right: renderer.right;
	width: renderer.width;
	height: renderer.height;
	name: "root";

	Protocol		{ id: protocol; enabled: true; }

	ColorTheme		{ id: colorTheme; }

	LocalStorage {
		id: choosenProvider;
		property string choosed: false;
		name: "choosenProvider";

		onCompleted: {
			this.read();
			this.choosed = choosenProvider.value;
			if (this.choosed)
				categoriesModel.provider = choosenProvider.value;
		}
	}

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

	ChannelsPanel {
		width: parent.portraitOrientation ? parent.width : parent.width - videoPlayer.width - 20;
		anchors.left: parent.left;
		anchors.top: parent.top;
		anchors.bottom: parent.bottom;
		anchors.leftMargin: 10;
		anchors.topMargin: parent.portraitOrientation ? videoPlayer.height + 20 : 0;
		visible: !providersPanel.active;

		onChannelSwitched(channel): { mainWindow.switchToChannel(channel); }
	}

	VideoPlayer {
		id: videoPlayer;
		anchors.top: mainWindow.top;
		anchors.right: mainWindow.right;
		anchors.rightMargin: renderer.fullscreen ? 0 : 10;
		anchors.topMargin: renderer.fullscreen ? 0 : 10;
		width: renderer.fullscreen ? renderer.width : 
			(mainWindow.portraitOrientation ? parent.width - 20 : parent.width / 2);
		height: renderer.fullscreen ? renderer.height : width / 3 * 2;
		source: lastChannel.source ? lastChannel.source : "http://hlsstr04.svc.iptv.rt.ru/hls/CH_NICKELODEON/variant.m3u8?version=2";
		autoPlay: true;

		Preloader {
			anchors.centerIn: videoPlayer;
			visible: !videoPlayer.ready;
		}
	}

	Controls {
		id: controls;
		anchors.fill: videoPlayer;
		visible: videoPlayer.visible;

		onFullscreenToggled:	{ renderer.fullscreen = !renderer.fullscreen; }
		onVolumeUpdated(value):	{ videoPlayer.volume = value; }
	}

	ProvidersPanel {
		id: providersPanel;
		active: !choosenProvider.choosed;

		onChoosed(provider): {
			choosenProvider.value = provider;
			categoriesModel.provider = provider;
		}
	}

	SettingsButton {
		anchors.bottom: renderer.bottom;
		anchors.right: renderer.right;

		onClicked: { providersPanel.start(); }
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

	switchToChannel(channel): {
		if (!channel) {
			log("App: Empty channel info.");
			return;
		}
		lastChannel.value = JSON.stringify(channel);
		videoPlayer.source = channel.url;
		controls.setChannelInfo(channel);
	}

	onHeightChanged:	{ this.updateLayout(); }
	onCompleted:		{ this.updateLayout(); }
}
