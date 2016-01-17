Rectangle {
	id: gameAreaProto;
	property bool stubbed: gpManager.count < 2;
	anchors.fill: parent;
	color: colorTheme.backgroundColor;

	GamepadManager {
		id: gpManager;
		property int maxSpeed: 50;
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
		width: 20;
		height: parent.height;
		anchors.horizontalCenter: parent.horizontalCenter;
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
}
