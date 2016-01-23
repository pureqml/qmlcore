Rectangle {
	id: gameAreaProto;
	property bool stubbed: gpManager.count < 2;
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
		anchors.rightMargin: 40;

		onValueChaned: { gameAreaProto.checkGameOver() }
	}

	Score {
		id: player2Score;
		anchors.top: sectionLine.top;
		anchors.left: sectionLine.right;
		anchors.leftMargin: 40;
	}

	Rectangle {
		id: ball;
		x: parent.width / 2;
		y: parent.height / 2;
		width: 40;
		height: width;
		color: colorTheme.itemsColor;
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
	}

	Timer {
		id: gameTimer;
		property int shift: 20;
		property int angle: 45;
		property real pi: 3.1415926;
		interval: 30;
		repeat: true;
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
				this.stop()
			} else if (newX + ball.width >= player2.x &&
				newY >= player2.y && newY <= player2.y + player2.height) {
				this.angle = -this.angle
				this.shift = -this.shift
			} else if (newX > gameAreaProto.width) {
				// Player2 missed ball
				++player1Score.value
				nextBallRestart.restart()
				this.stop()
			}
			ball.x = newX
			ball.y = newY
		}
	}

	checkGameOver: {
		if (player1Score.value >= 10)
		{
			gameTimer.stop()
		}
		else if (player2Score.value >= 10)
		{
		
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
