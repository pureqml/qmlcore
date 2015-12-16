Item {
	id: crazyBallProto;
	property int interval: 500;
	visible: true;

	Rectangle {
		id: ball;
		x: renderer.width / 2;
		y: renderer.height / 2;
		width: 100;
		height: width;
		color: "#f00";
		radius: width / 2;

		Behavior on x { Animation { duration: crazyBallProto.interval; } }
		Behavior on y { Animation { duration: crazyBallProto.interval; } }
		Behavior on width { Animation { duration: crazyBallProto.interval; } }
		Behavior on color { ColorAnimation { duration: crazyBallProto.interval; } }
	}

	Timer {
		interval: crazyBallProto.interval;
		repeat: true;
		running: parent.visible;
		triggeredOnStart: true;

		onTriggered: {
			var colors = ["#CE93D8", "#FF8A80", "#90CAF9", "#80CBC4", "#F0F4C3", "#D7CCC8", "#FFCCBC"]
			ball.color = colors[Math.round(Math.random() * (colors.length - 1))]
			ball.x = Math.random() * 1280
			ball.y = Math.random() * 720
			ball.width = Math.random() * 100 + 50
		}
	}
}
