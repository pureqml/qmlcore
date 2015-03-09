Activity {
	id: mainWindow;
	anchors.fill: renderer;
	anchors.leftMargin: 75;
	anchors.rightMargin: 75;
	anchors.bottomMargin: 40;
	anchors.topMargin: 42;

	VideoPlayer { id: videoPlayer; anchors.fill: renderer; autoPlay: true; }

	Protocol { id: proto; enabled: true; }

	MouseArea {
		id: area;
		anchors.fill: renderer;
		hoverEnabled: !parent.hasAnyActiveChild || parent.currentActivity == "infoPlate";

		onMouseXChanged: { 
			if (this.hoverEnabled) 
				infoPlate.show(2000); 
		}

		onMouseYChanged: {
			if (this.hoverEnabled) 
				infoPlate.show(2000); 
		}
	}

	CategoriesList {
		id: categories;
		anchors.leftMargin: 60;
		anchors.rightMargin: 60;
		protocol: proto;
		anchors.fill: parent;

		onActivated(url): {
			log("got url", url)
			videoPlayer.source = url
			videoPlayer.play();
		}

		onChannelSwitched(channelInfo): {
			infoPlate.fillChannelInfo(channelInfo);
			infoPlate.updateEpg();
			infoPlate.show(10000);
		}
	}

	InfoPlate {
		id: infoPlate;
		signal epgUpdated;
		anchors.fill: parent;

		Timer {
			duration: 5000;
			reapeat: true;
			running: infoPlate.active;
			triggeredOnStart: true;

			onTriggered: { infoPlate.updateEpg(); }
		}

		updateEpg: {
			var epgUpdated = infoPlate.epgUpdated;
			categories.getProgramInfo(function(programInfo) {
				if (programInfo)
					epgUpdated(programInfo);
				else
					log("Failed to get program info");
			});
		}

		onEpgUpdated(programInfo): { infoPlate.fillProgramInfo(programInfo); }
		onChannelUp: { categories.channelUp(); }
		onChannelDown: { categories.channelDown(); }

		onOptionChoosed(text): {
			if (text == "ТВ меню")
				mainMenu.start();
			else if (text == "ТВ Гид")
				tvGuide.start();
			else if (text == "Список каналов")
				categories.start();
		}
	}

	Text {
		anchors.horizontalCenter: parent.horizontalCenter;
		color: "white";
		text: "Нажмите F4 или двигайте мышкой, чтобы показать инфопанель";
		opacity: infoPlate.active || categories.active ? 0.0 : 1.0;

		Behavior on opacity { Animation { duration: 300; } }
	}

	onBluePressed: {
		log("onBluePressed");
		if (!categories.active)
			infoPlate.show(10000);
	}

	MainMenu {
		id: mainMenu;
		visible: false;

		onTvGuideChoosed: {
			mainMenu.stop();
			tvGuide.start();
		}
	}

	TVGuide {
		id: tvGuide;
		visible: false;
		protocol: proto;
	}

	Mouse {
		x: area.mouseX - 74;
		y: area.mouseY - 41;
		z: 10;
	}

	//TODO: make it more platform independing.
	onBackPressed: {
		//TODO: use activitymanager when it's done.
		if (_globals.core.vendor == "samsung" && !infoPlate.active && !tvGuide.active && !mainMenu.active && !categories.active)
			widgetAPI.sendExitEvent();
	}

	onRedPressed: { tvGuide.start(); }
	onGreenPressed: { categories.start(); }
}
