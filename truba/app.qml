Activity {
	id: mainWindow;
	anchors.fill: renderer;
	anchors.topMargin: 70;
	name: "root";

	Protocol		{ id: protocol; enabled: true; }
	ColorTheme		{ id: colorTheme; }

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
		width: fullscreen ? renderer.width : 520;
		height: fullscreen ? renderer.height : 400;
		anchors.top: renderer.top;
		anchors.right: renderer.right;
		anchors.rightMargin: fullscreen ? 0 : 20;
		anchors.topMargin: fullscreen ? 0 : 20;
		source: "http://hlsstr04.svc.iptv.rt.ru/hls/CH_NICKELODEON/variant.m3u8?version=2";
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
			videoPlayer.fullscreen = true;
			renderer.enterFullscreenMode();
		}
	}

	ChannelsPanel {
		id: channelsPanel;
		anchors.top: topMenu.bottom;
		anchors.left: renderer.left;
		anchors.bottom: renderer.bottom;
		anchors.topMargin: 2;
		protocol: parent.protocol;

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
	}

	onBackPressed: {
		if (videoPlayer.fullscreen) {
			renderer.exitFullscreenMode();
			videoPlayer.fullscreen = false;
		}
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
}
