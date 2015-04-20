Activity {
	id: mainWindow;
	anchors.fill: renderer;
	anchors.topMargin: 70;
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

	Rectangle {
		id: background;
		anchors.fill: renderer;
		color: colorTheme.disabledBackgroundColor;
	}

	VideoPlayer {
		id: videoPlayer;
		property bool fullscreen: false;
		width: fullscreen ? renderer.width : renderer.width / 3;
		height: fullscreen ? renderer.height : width * 2 / 3;
		anchors.top: renderer.top;
		anchors.right: renderer.right;
		anchors.rightMargin: fullscreen ? 0 : 20;
		anchors.topMargin: fullscreen ? 0 : 20;
		source: lastChannel.value ? lastChannel.value : "http://hlsstr04.svc.iptv.rt.ru/hls/CH_NICKELODEON/variant.m3u8?version=2";
		autoPlay: true;
		z: 10000;
	}

	ControlsSmall {
		anchors.left: videoPlayer.left;
		anchors.right: videoPlayer.right;
		anchors.bottom: videoPlayer.bottom;
		volume: videoPlayer.volume;
		visible: !videoPlayer.fullscreen;
		z: videoPlayer.z + 1;

		onFullScreenClicked: {
			videoPlayer.fullscreen = true
			renderer.fullscreen = true
		}
	}

	ChannelsPanel {
		id: channelsPanel;
		anchors.top: topMenu.bottom;
		anchors.left: renderer.left;
		anchors.bottom: renderer.bottom;
		anchors.topMargin: 2;
		protocol: parent.protocol;

		onFocusPropagated: { channelInfo.forceActiveFocus(); }

		onChannelSwitched(channel): { mainWindow.switchToChannel(channel); }
	}

	TopMenu {
		id: topMenu;

		onSearchRequest(request): {
		//TODO: impl
		}

		onDownPressed: { channelsPanel.forceActiveFocus(); }
	}

	ChannelInfo {
		id: channelInfo;
		anchors.left: videoPlayer.left;
		anchors.right: videoPlayer.right;
		anchors.top: videoPlayer.bottom;
		anchors.bottom: renderer.bottom;
		anchors.topMargin: 10;
		visible: channelsPanel.active;

		onLeftPressed: { channelsPanel.forceActiveFocus(); }
	}

	function backToWindowedMode() {
		if (videoPlayer.fullscreen) {
			renderer.fullscreen = false
			videoPlayer.fullscreen = false
		}
	}

	onBackPressed: {
		this.backToWindowedMode()
	}

	//MouseArea {
		//anchors.fill: renderer;
		//hoverEnabled: !parent.hasAnyActiveChild;

		//onMouseXChanged: { 
			//if (this.hoverEnabled)
				//infoPanel.active = true;
		//}

		//onMouseYChanged: {
			//if (this.hoverEnabled) 
				//infoPanel.active = true;
		//}
	//}

	//SettingsPanel {
		//id: settings;
		//anchors.fill: activityArea;
		//protocol: parent.protocol;

		//onLeftPressed:	{ mainMenu.forceActiveFocus(); }
		//onUpPressed:	{ topMenu.forceActiveFocus(); }
	//}

	//SearchPanel {
		//id: searchPanel;
		//protocol: parent.protocol;
		//anchors.fill: activityArea;

		//onChannelSwitched(channel): { mainWindow.switchToChannel(channel); }
		//onUpPressed: { topMenu.forceActiveFocus(); }
	//}

	//MuteIcon { mute: videoPlayer.volume <= 0; }

	//InfoPanel {
		//id: infoPanel;
		//height: 200;
		//anchors.bottom: parent.bottom;
		//anchors.left: parent.left;
		//anchors.right: parent.right;
		//protocol: parent.protocol;
		//volume: videoPlayer.volume;

		//onMenuCalled:		{ mainMenu.start(); }
		//onVolumeUpdated(v):	{ videoPlayer.volume = v; }

		//onUpPressed: {
			//if (mainMenu.active)
				//mainMenu.forceActiveFocus();
		//}
	//}

	switchToChannel(channel): {
		if (!channel) {
			log("App: Empty channel info.");
			return;
		}
		lastChannel.value = channel.url;
		videoPlayer.source = channel.url;
		channelInfo.fillInfo(channel);
		//infoPanel.fillChannelInfo(channel);
	}

	//onUpPressed:		{ videoPlayer.volumeUp(); }
	//onDownPressed:		{ videoPlayer.volumeDown(); }
	//onRedPressed:		{ vodPanel.start(); }
	//onBluePressed:		{ infoPanel.active = true; }
	//onGreenPressed:		{ channelsPanel.start(); }
	//onYellowPressed:	{ epgPanel.start(); }

	//onBackPressed: {
		//if (!infoPanel.active && !mainMenu.active && !mainWindow.hasAnyActiveChild) {
			//event.accepted = false;
			//return true;
		//}
		//if (mainWindow.hasAnyActiveChild)
			//mainWindow.closeAll();
		//if (infoPanel.active)
			//infoPanel.active = false;
		//if (mainMenu.active)
			//mainMenu.active = false;
	//}

	//onMenuPressed: {
		//if (mainMenu.active) {
			//mainMenu.active = false;
		//} else {
			//mainMenu.active = true;
			//mainMenu.forceActiveFocus();
		//}
	//}

	onCompleted: {
		channelsPanel.active = true;
		var self = this;
		renderer.onChanged('fullscreen', function(value) {
			if (!value)
				self.backToWindowedMode()
		})
	}
}
