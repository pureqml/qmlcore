Activity {
	id: mainWindow;
	anchors.fill: renderer;
	name: "root";

	ColorTheme { id: colorTheme; }

	GameArea {
		id: game;
	}

	//Text {
		//anchors.centerIn: parent;
		//text: "INSERT 2 GAMEPADS";
		//color: "#fff";
		//font.pixelSize: 46;
		//visible: game.stubbed;
	//}
}
