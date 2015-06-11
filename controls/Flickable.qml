Item {
	property Item contentItem: Item {}

	property int contentHeight: contentItem.height;
	property int contentWidth: contentItem.width;
	property alias contentX: contentItem.x;
	property alias contentY: contentItem.y;

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
			this._y = this.mouseX
			this.parent.move(0, -dy);
		}
	}

	move(dx, dy): {
		var x, y
		if (this.contentWidth > this.width) {
			x = this.contentX + dx
			if (x < 0)
				x = 0
			else if (x > this.contentWidth - this.width)
				x = this.contentWidth - this.width
			this.contentX = x
		}
		if (this.contentHeight > this.height) {
			y = this.contentY + dy
			if (y < 0)
				y = 0
			else if (y > this.contentHeight - this.height)
				y = this.contentHeight - this.height
			this.contentY = y
		}
	}
}
