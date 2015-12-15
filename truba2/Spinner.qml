Item {
	anchors.fill: renderer;

	Text {
		anchors.centerIn: parent;
		text: "Загрузка...";
		color: colorTheme.textColor;
		font.pixelSize: 48;
		font.shadow: true;
	}

	CrazyBall { interval: 500; }
	CrazyBall { interval: 600; }
	CrazyBall { interval: 700; }
}
