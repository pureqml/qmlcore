Activity {
	id: mainWindow;
	anchors.fill: renderer;
	name: "root";

	ColorTheme { id: colorTheme; }

	GameArea {
		id: game;
	}
}
