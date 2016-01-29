Item {
	anchors.fill: renderer;

	Text {
		id: loadingText;
		anchors.centerIn: parent;
		text: "Загрузка";
		color: colorTheme.textColor;
		font.pixelSize: 48;
		font.shadow: true;

		Behavior on color { ColorAnimation { duration: 300; } }
	}

	Timer {
		property int iter: 0;
		interval: 300;
		repeat: true;
		running: parent.visible;
		triggeredOnStart: true;

		onTriggered: {
			var colors = ["#CE93D8", "#FF8A80", "#90CAF9", "#80CBC4", "#F0F4C3", "#D7CCC8", "#FFCCBC"]
			loadingText.color = colors[Math.round(Math.random() * (colors.length - 1))]
			if (this.iter >= 3) {
				this.iter = 0
				loadingText.text = "Загрузка"
			} else {
				++this.iter
				loadingText.text += "."
			}
		}
	}
}
