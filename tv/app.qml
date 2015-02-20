Item {
	id: mainWindow;
	anchors.fill: renderer;
	anchors.leftMargin: 75;
	anchors.rightMargin: 75;
	anchors.bottomMargin: 40;
	anchors.topMargin: 42;

	CategoriesList {
		anchors.leftMargin: 60;
		anchors.rightMargin: 60;
	}

	InfoPlate {
		id: infoPlate;
		anchors.fill: parent;
	}

	Text {
		anchors.centerIn: parent;
		text: "Нажми F4 или подергай мышкой, штоп показать инфобаннер";
	}

	onBluePressed: {
		infoPlate.show();
	}
}
