Item {
	property Item contentItem;

	property alias contentHeight: content.height;
	property alias contentWidth: content.width;
	property alias contentX: content.x;
	property alias contentY: content.y;

	property bool pageScrolling: false;
	property bool dragging;
	property bool draggingHorizontally;
	property bool draggingVertically;

	clip: true;

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
		Behavior on x { Animation { duration: 300; } }
		Behavior on y { Animation { duration: 300; } }
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
			this.parent.move(dx, 0);
		}

		onMouseYChanged: {
			if (!this.pressed || !this.parent.draggingVertically)
				return

			var dy = this.mouseY - this._y
			this._y = this.mouseY
			this.parent.move(0, dy);
		}

		onPressedChanged: {
			this.checkInnerItemsPressed(this.parent.content, value);

			if (!this.pressed)
				return
			this._x = this.mouseX
			this._y = this.mouseY
		}

		onVerticalSwiped(event): {
			if (!event || !this.parent.draggingVertically)
				return

			var a = this.parent.getAnimation('contentY')
			if (a)
				a.disable()
			this.parent.move(0, event.dy)
			if (a)
				a.enable()
		}

		onWheelEvent(dp): {
			if (this.parent.draggingVertically || this.parent.dragging) {
				var dy = this.parent.pageScrolling ? Math.round(dp) * this.parent.height : Math.round(dp) * this.parent.contentHeight / 10
				this.parent.move(0, dy)
			}
		}

		checkInnerItems(item): {
			if (!item || !item.children)
				return;

			for (var i = 0; i < item.children.length; ++i) {
				if (item.children[i] instanceof qml.core.Layout || item.children[i] instanceof qml.core.BaseView)
					this.checkInnerItems(item.children[i])

				if (item.children[i] instanceof qml.core.MouseArea)
					item.children[i].clicked()
			}
		}

		checkInnerItemsPressed(item, value): {
			if (!item || !item.children)
				return;

			for (var i = 0; i < item.children.length; ++i) {
				if (item.children[i] instanceof qml.core.Layout || item.children[i] instanceof qml.core.BaseView)
					this.checkInnerItemsPressed(item.children[i], value)

				if (item.children[i] instanceof qml.core.MouseArea)
					item.children[i].pressed = value
			}
		}

		onClicked: { this.checkInnerItems(this.parent.content); }
	}

	move(dx, dy): {
		var x, y
		if (this.contentWidth > this.width) {
			x = this.contentX + dx
			if (x > 0)
				x = 0
			else if (x < this.width - this.contentWidth)
				x = this.width - this.contentWidth
			this.contentX = x
		}
		if (this.contentHeight > this.height) {
			y = this.contentY + dy
			if (y > 0)
				y = 0
			else if (y < this.height - this.contentHeight)
				y = this.height - this.contentHeight
			this.contentY = y
		}
	}

	onCompleted: {
		this.content = this.contentItem;
		this.content.x = 0;
		this.content.y = 0;
	}
}
