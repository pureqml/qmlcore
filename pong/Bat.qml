Rectangle {
	id: batProto;
	width: 40;
	height: 150;
	color: colorTheme.itemsColor;
	property int maxSpeed: 2;
	property real speed: 0.0;

	onSpeedChanged: { resetSpeedTimer.restart() }
	speedUp: { this.speed = this.speed >= this.maxSpeed ? this.maxSpeed : (this.speed + 0.5) }

	Timer {
		id: resetSpeedTimer;
		interval: 1000;

		onTriggered: { batProto.speed = 0 }
	}

	Behavior on y { Animation { duration: 300; } }
}
