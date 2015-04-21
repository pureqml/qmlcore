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

	VideoPlayer {
		id: videoPlayer;
		anchors.fill: renderer;
		source: lastChannel.value ? lastChannel.value : "http://hlsstr04.svc.iptv.rt.ru/hls/CH_NICKELODEON/variant.m3u8?version=2";
		autoPlay: true;
	}

	MouseArea {
		anchors.fill: renderer;
		hoverEnabled: !parent.hasAnyActiveChild;

		onMouseXChanged: {
			if (this.hoverEnabled)
				controls.show();
		}

		onMouseYChanged: {
			if (this.hoverEnabled)
				controls.show();
		}
	}

	Timer {
		id: hideControlsTimer;
		interval: 5000;

		onTriggered: { controls.active = false; }
	}

	Item {
		id: controls;
		property bool active: false;
		opacity: active ? 1.0 : 0.0;

		RoundButton {
			id: listsButton;
			anchors.top: renderer.top;
			anchors.left: renderer.left;
			anchors.margins: 30;
			icon: "res/list.png";
			visible: !mainWindow.hasAnyActiveChild;

			onToggled: { channelsPanel.start(); }
		}

		RoundButton {
			id: fullscreenButton;
			anchors.bottom: renderer.bottom;
			anchors.right: renderer.right;
			anchors.margins: 30;
			icon: "res/fullscreen.png";
			visible: !mainWindow.hasAnyActiveChild;

			onToggled: { renderer.fullscreen = true; }
		}

		show: {
			this.active = true;
			hideControlsTimer.restart();
		}

		Behavior on opacity { Animation { duration: 300; } }
	}

	ChannelsPanel {
		id: channelsPanel;
		anchors.top: renderer.top;
		anchors.left: renderer.left;
		anchors.bottom: renderer.bottom;
		protocol: parent.protocol;

		onFocusPropagated: { channelInfo.forceActiveFocus(); }

		onChannelSwitched(channel): { mainWindow.switchToChannel(channel); }
	}

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

	MuteIcon { mute: videoPlayer.volume <= 0.1; z: videoPlayer.z + 10; }

	//InfoPanel {
		//id: infoPanel;
		//height: 200;
		//anchors.bottom: videoPlayer.bottom;
		//anchors.left: videoPlayer.left;
		//anchors.right: videoPlayer.right;
		//protocol: parent.protocol;
		//volume: videoPlayer.volume;
		//active: videoPlayer.fullscreen;
		//visible: videoPlayer.fullscreen;
		//z: videoPlayer.z + 1;

		//onVolumeUpdated(v):	{ videoPlayer.volume = v; }
	//}

	ChannelInfo {
		id: channelInfo;
		height: renderer.height / 2;
		anchors.left: renderer.left;
		anchors.right: channelsPanel.right;
		anchors.bottom: renderer.bottom;
		anchors.leftMargin: 260;
		visible: channelsPanel.active;

		onUpPressed: { channelsPanel.forceActiveFocus(); }
	}

	switchToChannel(channel): {
		if (!channel) {
			log("App: Empty channel info.");
			return;
		}
		lastChannel.value = channel.url;
		videoPlayer.source = channel.url;
		channelInfo.fillInfo(channel);
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

	onVisibleChanged: {
		if (this.visible)
			controls.show();
	}
}
