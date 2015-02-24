Item {
	id: mainWindow;
	anchors.fill: renderer;
	anchors.leftMargin: 75;
	anchors.rightMargin: 75;
	anchors.bottomMargin: 40;
	anchors.topMargin: 42;

	VideoPlayer { id: videoPlayer; anchors.fill: renderer; autoPlay: true; }

	Protocol { id: proto; enabled: true; }

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

			infoPlate.show();
		}

		onEpgUpdated(programInfo): {
			infoPlate.programTitle = programInfo.title;
			infoPlate.programDescription = programInfo.description;

			var now = new Date();
			var startTime = new Date(programInfo.startTime * 1000);
			var endTime = new Date((programInfo.startTime + programInfo.duration) * 1000);
			var minutes = startTime.getMinutes();
			minutes = minutes >= 10 ? minutes : "0" + minutes;
			infoPlate.programInfo = startTime.getHours() + ":" + minutes;
			var minutes = endTime.getMinutes();
			minutes = minutes >= 10 ? minutes : "0" + minutes;
			infoPlate.programInfo += " - " + endTime.getHours() + ":" + minutes;
			infoPlate.programInfo += ", " + programInfo.channel;
			infoPlate.programInfo += ", " + programInfo.genre;
			infoPlate.programInfo += ", " + programInfo.age + "+";

			infoPlate.programProgress = (now - startTime) / (endTime - startTime);
		}
	}

	InfoPlate {
		id: infoPlate;
		anchors.fill: parent;
		visible: !categories.active;

		onChannelListCalled: {
			infoPlate.permanent = false;
			categories.toggle();
		}
	}

	Text {
		anchors.centerIn: parent;
		color: "white";
		text: "Нажмите F4 или двигайте мышкой, чтобы показать инфопанель";
		opacity: infoPlate.active || categories.active ? 0.0 : 1.0;

		Behavior on opacity { Animation { duration: 300; } }
	}

	onBluePressed: { infoPlate.permanent = true; infoPlate.show(); }
	onGreenPressed: { categories.toggle(); }
}
