Item {
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
		hoverEnabled: !categories.active;

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
			console.log("got url", url)
			videoPlayer.source = url
			videoPlayer.play();
		}

		onChannelSwitched(channelInfo): {
			infoPlate.isHd = channelInfo.isHd;
			infoPlate.is3d = channelInfo.is3d;
			infoPlate.title = channelInfo.title;
			infoPlate.logo = channelInfo.logo;
			infoPlate.channelNumber = channelInfo.number;

			infoPlate.show(10000);
		}

		onStarted: {
			infoPlate.stop();
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

			onTriggered: {
				var epgUpdated = infoPlate.epgUpdated;
				categories.getProgramInfo(function(programInfo) {
					if (programInfo)
						epgUpdated(programInfo);
					else
						console.log("Failed to get program info");
				});
			}
		}

		onEpgUpdated(programInfo): {
			infoPlate.programTitle = programInfo.title;
			infoPlate.programTitle = programInfo.title;
			infoPlate.programDescription = programInfo.description;

			var now = new Date();
			infoPlate.programInfo = programInfo.info;
			infoPlate.programProgress = (now - programInfo.startTime) / (programInfo.endTime - programInfo.startTime);
		}

		onChannelListCalled: {
			this.stop();
			categories.start();
		}

		onOptionChoosed(text): {
			//if (text == "ТВ меню")
				//mainMenu.show();
		}
	}

	Text {
		anchors.horizontalCenter: parent.horizontalCenter;
		color: "white";
		text: "Нажмите F4 или двигайте мышкой, чтобы показать инфопанель";
		opacity: infoPlate.active || categories.active ? 0.0 : 1.0;

		Behavior on opacity { Animation { duration: 300; } }
	}

	//MainMenu {
		//id: mainMenu;
		//visible: false;
	//}

	Mouse {
		x: area.mouseX - 74;
		y: area.mouseY - 41;
		z: 10;
	}

	onBluePressed: { 
		if (!categories.active)
			infoPlate.show(10000); 
	}

	onGreenPressed: { categories.start(); }
}
