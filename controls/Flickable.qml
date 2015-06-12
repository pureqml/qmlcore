Item {
	property Item contentItem;

	property alias contentHeight: content.height;
	property alias contentWidth: content.width;
	property alias contentX: content.x;
	property alias contentY: content.y;

	property bool dragging;
	property bool draggingHorizontally;
	property bool draggingVertically;

	//TODO: Implement.
	//property bool atXBeginning;
	//property bool atXEnd;
	//property bool atYBeginning;
	//property bool atYEnd;
	//property int topMargin;
	//property int bottomMargin;
	//property int rightMargin;
	//property int leftMargin;
	//property bool moving;
	//property bool movingHorizontally;
	//property bool movingVertically;
	//property real flickDeceleration;
	//property bool flicking;
	//property bool flickingHorizontally;
	//property bool flickingVertically;
	//property real horizontalVelocity;
	//property bool interactive;
	//property real maximumFlickVelocity;
	//property real originX;
	//property real originY;
	//property bool pixelAligned;
	//property int pressDelay;
	//property real verticalVelocity;
	//property enumeration boundsBehavior;
	//property enumeration flickableDirection;
	//property visibleArea
	//property visibleArea.xPosition : real
	//property visibleArea.widthRatio : real
	//property visibleArea.yPosition : real
	//property visibleArea.heightRatio : real

	content: Item {
		Behavior on x	{ Animation { duration: 300; } }
		Behavior on y	{ Animation { duration: 300; } }
	}

	MouseArea {
		anchors.fill: parent;
		hoverEnabled: parent.dragging;
		z: parent.z + 10;

		onMouseXChanged: {
			if (!this.pressed || !this.parent.draggingHorizontally)
				return

			var dx = this.mouseX - this._x
			this._x = this.mouseX
			this.parent.move(-dx, 0);
		}

		onMouseYChanged: {
			if (!this.pressed || !this.parent.draggingVertically)
				return

			var dy = this.mouseY - this._y
			this._y = this.mouseY
			this.parent.move(0, -dy);
		}

		onPressedChanged: {
			if (!this.pressed)
				return
			this._x = this.mouseX
			this._y = this.mouseY
		}
	}

	move(dx, dy): {
		var x, y
		x = this.contentX + dx
		this.contentX = x
		y = this.contentY + dy
		this.contentY = y
	}

	onCompleted: {
		this.content = this.contentItem;
		this.content.x = 0;
		this.content.y = 0;
	}
}
