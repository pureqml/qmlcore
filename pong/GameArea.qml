Rectangle {
	id: gameAreaProto;
	property bool gameStopped: false;
	property int maxCount: 10;
	anchors.fill: parent;
	color: colorTheme.backgroundColor;
	focus: true;

	GamepadManager {
		id: gpManager;
		property int maxSpeed: 100;
		anchors.fill: parent;

		Gamepad {
			id: gamepad1;
			property int speed: 0;

			updatePosition(val): {
				this.speed = gpManager.maxSpeed * val
				var newVal = player1.y + this.speed
				var max = gameAreaProto.height - player1.height
				player1.y = newVal < 0 ? 0 : (newVal >= max ? max : newVal)
			}

			onLeftJoystickX(value): { this.updatePosition(value) }
			onRightJoystickY(value): { this.updatePosition(value) }
		}

		Gamepad {
			id: gamepad2;
			property int speed: 0;

			updatePosition(val): {
				this.speed = gpManager.maxSpeed * val
				var newVal = player2.y + this.speed
				var max = gameAreaProto.height - player2.height
				player2.y = newVal < 0 ? 0 : (newVal >= max ? max : newVal)
			}

			onLeftJoystickX(value): { this.updatePosition(value) }
			onRightJoystickY(value): { this.updatePosition(value) }
		}
	}

	Rectangle {
		id: sectionLine;
		width: 20;
		height: parent.height;
		anchors.horizontalCenter: parent.horizontalCenter;
		color: colorTheme.itemsColor;
	}

	Score {
		id: player1Score;
		anchors.top: sectionLine.top;
		anchors.right: sectionLine.left;
		anchors.topMargin: 20;
		anchors.rightMargin: 40;
	}

	Score {
		id: player2Score;
		anchors.top: sectionLine.top;
		anchors.left: sectionLine.right;
		anchors.topMargin: 20;
		anchors.leftMargin: 40;
	}

	Rectangle {
		id: ball;
		x: parent.width / 2;
		y: parent.height / 2;
		width: 40;
		height: width;
		color: colorTheme.itemsColor;
		visible: !gameAreaProto.gameStopped;
	}

	Bat {
		id: player1;
		anchors.left: parent.left;
	}

	Bat {
		id: player2;
		anchors.right: parent.right;
	}

	Timer {
		id: nextBallRestart;
		interval: 1000;

		onTriggered: {
			ball.x = gameAreaProto.width / 2
			ball.y = gameAreaProto.height / 2
			gameTimer.shift = -gameTimer.shift
			gameTimer.angle = Math.random() * 90 - 45
			gameTimer.restart()
		}
	}

	MouseArea {
		anchors.fill: parent;
		hoverEnabled: true;

		onMouseYChanged: {
			if (gpManager.count < 2)
				player2.y = value
		}

		onClicked: { gameAreaProto.restart() }
	}

	Column {
		width: parent.width;
		anchors.centerIn: parent;
		visible: parent.gameStopped;

		Text {
			width: parent.width;
			text: "GAME OVER!";
			horizontalAlignment: Text.AlignHCenter;
			color: colorTheme.itemsColor;
			font.pixelSize: 52;
			font.shadow: true;
		}

		Text {
			width: parent.width;
			text: "PRESS 'ENTER' TO RESTART";
			horizontalAlignment: Text.AlignHCenter;
			color: colorTheme.itemsColor;
			font.pixelSize: 42;
			font.shadow: true;
		}
	}

	Timer {
		id: gameTimer;
		property int shift: 10;
		property int angle: 45;
		property real pi: 3.1415926;
		interval: 20;
		repeat: !gameAreaProto.gameStopped;
		triggerOnStart: true;

		onTriggered: {
			var newX = ball.x + this.shift * Math.cos(this.angle * this.pi / 180)
			var newY = ball.y + this.shift * Math.sin(this.angle * this.pi / 180)

			if (newY <= 0) {
				this.angle = -this.angle
			} else if (newY >= gameAreaProto.height - ball.height) {
				this.angle = -this.angle
			} else if (newX <= player1.x + player1.width && 
				newY >= player1.y && newY <= player1.y + player1.height) {
				this.angle = -this.angle
				this.shift = -this.shift
			} else if (newX + ball.width <= 0) {
				// Player1 missed ball
				++player2Score.value
				nextBallRestart.restart()
				gameAreaProto.checkGameOver()
				this.stop()
			} else if (newX + ball.width >= player2.x &&
				newY >= player2.y && newY <= player2.y + player2.height) {
				this.angle = -this.angle
				this.shift = -this.shift
			} else if (newX > gameAreaProto.width) {
				// Player2 missed ball
				++player1Score.value
				nextBallRestart.restart()
				gameAreaProto.checkGameOver()
				this.stop()
			}
			ball.x = newX
			ball.y = newY
		}
	}

	onSelectPressed: { this.restart() }

	restart: {
		player1Score.value = 0
		player2Score.value = 0
		this.gameStopped = false
		nextBallRestart.restart()
	}

	checkGameOver: {
		if (player1Score.value >= this.maxCount) {
			this.gameStopped = true
			gameTimer.stop()
		} else if (player2Score.value >= this.maxCount) {
			this.gameStopped = true
			gameTimer.stop()
		}
	}

	onUpPressed: {
		if (gpManager.count == 0) {
			player1.speedUp()
			gamepad1.updatePosition(-player1.speed)
		}
	}

	onDownPressed: {
		if (gpManager.count == 0) {
			player1.speedUp()
			gamepad1.updatePosition(player1.speed)
		}
	}

	onCompleted: {
		gameTimer.restart()
	}
}
