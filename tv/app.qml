Item {
	id: mainWindow;
	anchors.fill: renderer;
	anchors.leftMargin: 75;
	anchors.rightMargin: 75;
	anchors.bottomMargin: 40;
	anchors.topMargin: 42;

	VideoPlayer { id: videoPlayer; anchors.fill: renderer; }

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
		}

		onChannelSwitched(channelInfo): {
			infoPlate.isHd = channelInfo.isHd;
			infoPlate.is3d = channelInfo.is3d;
			infoPlate.description = channelInfo.description;
			infoPlate.title = channelInfo.title;
			infoPlate.logo = channelInfo.logo;
			infoPlate.channelNumber = channelInfo.number;
		}
	}

	InfoPlate {
		id: infoPlate;
		anchors.fill: parent;
	}

	Text {
		anchors.centerIn: parent;
		color: "white";
		text: "Нажми F4 или подергай мышкой, штоп показать инфобаннер";
		opacity: infoPlate.active || categories.active ? 0.0 : 1.0;

		Behavior on opacity { Animation { duration: 300; } }
	}

	onBluePressed: { infoPlate.show(); }
	onGreenPressed: { categories.toggle(); }
}
