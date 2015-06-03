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
			if (channelInfo) {
				mainWindow.switchToChannel(channelInfo);
				if (channelInfo.categoryIndex)
					channelsPanel.setCategoryIndex(channelInfo.categoryIndex);
			}
		}
	}

	ProvidersModel {
		id: providersModel;
		protocol: protocol;

		onDefaultProviderChanged: {
			if (!choosenProvider.choosed && value) {
				categoriesModel.provider = value;
				choosenProvider.choosed = true;
			}
		}
	}

	CategoriesModel	{ id: categoriesModel;	protocol: protocol; }
	EPGModel		{ id: epgModel;			protocol: protocol; }

	Timer {
		id: updateTimer;
		interval: 24 * 3600 * 1000;
		repeat: true;

		onTriggered: {
			categoriesModel.update();
			epgModel.update();
		}
	}

	VideoPlayer {
		id: videoPlayer;
		anchors.top: mainWindow.top;
		anchors.right: mainWindow.right;
		anchors.rightMargin: renderer.fullscreen ? 0 : 10;
		anchors.topMargin: renderer.fullscreen ? 0 : (mainWindow.portraitOrientation ? 50 : 10);
		width: renderer.fullscreen ? renderer.width : 
			(mainWindow.portraitOrientation ? parent.width - 20 : parent.width / 2);
		height: renderer.fullscreen ? renderer.height : width / 3 * 2;
		source: lastChannel.source ? lastChannel.source : "http://hlsstr04.svc.iptv.rt.ru/hls/CH_NICKELODEON/variant.m3u8?version=2";
		visible: !hintText.visible;
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

	ProgramInfo {
		id: progrmInfo;
		height: parent.portraitOrientation ? videoPlayer.height / 2 : parent.height - videoPlayer.height - 20;
		anchors.left: videoPlayer.left;
		anchors.right: videoPlayer.right;
		anchors.top: videoPlayer.bottom;
		anchors.margins: 10;
		visible: !hintText.visible && !renderer.fullscreen;
	}

	ChannelsPanel {
		id: channelsPanel;
		width: parent.portraitOrientation ? parent.width : parent.width - videoPlayer.width - 20;
		anchors.left: parent.left;
		anchors.top: parent.top;
		anchors.bottom: parent.bottom;
		anchors.leftMargin: 10;
		spacing: parent.portraitOrientation ? videoPlayer.height + progrmInfo.height + 20 : 0;
		visible: !hintText.visible && !renderer.fullscreen;

		onChannelSwitched(channel): { mainWindow.switchToChannel(channel); }
		onProgramSelected(program):	{ progrmInfo.setProgram(program); }
	}

	Text {
		id: hintText;
		anchors.centerIn: parent;
		color: colorTheme.disabledTextColor;
		text: !categoriesModel.count ? "Нет каналов" : (!choosenProvider.choosed ? "Не указан провайдер" : "");
		font.pointSize: 32;
		visible: !choosenProvider.choosed || !categoriesModel.count;
	}

	SettingsPanel {
		id: settingsPanel;
		active: !choosenProvider.choosed;
		width: active ? (mainWindow.portraitOrientation ? parent.width / 2 : parent.width / 4) : 0;
		anchors.top: parent.top;
		anchors.right: renderer.right;
		anchors.bottom: parent.bottom;

		onChoosed(provider): {
			choosenProvider.value = provider;
			categoriesModel.provider = provider;
			choosenProvider.choosed = provider;
		}
	}

	SettingsButton {
		id: settingButton;
		anchors.top: parent.top;
		anchors.topMargin: parent.height - 50;
		anchors.right: renderer.right;
		visible: !renderer.fullscreen;

		onClicked: {
			if (settingsPanel.active)
				settingsPanel.stop();
			else
				settingsPanel.start();
		}
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
		progrmInfo.setChannel(channel);
		progrmInfo.setProgram(channel.program);
	}

	onHeightChanged:	{ this.updateLayout(); }
	onCompleted:		{ this.updateLayout(); }
}
