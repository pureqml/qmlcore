Item {
	property Object model;
	property Item delegate;

	property int count;
	property int currentIndex;

	property int contentX;
	property int contentY;
	property int contentWidth: 1;
	property int contentHeight: 1;

	property bool handleNavigationKeys: true;
	property bool keyNavigationWraps: true;
	property bool dragEnabled: true;
	property bool contentFollowsCurrentItem: true;
	property bool pageScrolling: false;

	property bool trace;

	signal clicked;

	itemAt(x, y): {
		var idx = this.indexAt(x, y)
		return idx >= 0? this._items[idx]: null
	}

	positionViewAtIndex(idx): {
		var cx = this.contentX, cy = this.contentY
		var itemBox = this.getItemPosition(idx)
		var x = itemBox[0], y = itemBox[1]
		var iw = itemBox[2], ih = itemBox[3]
		var w = this.width, h = this.height
		var horizontal = this.orientation == this.Horizontal
		if (horizontal) {
			if (iw > w) {
				this.contentX = x - w / 2 + iw / 2
				return
			}
			if (x - cx < 0)
				this.contentX = x
			else if (x - cx + iw > w)
				this.contentX = x + iw - w
		} else {
			if (ih > h) {
				this.contentY = y - h / 2 + ih / 2
				return
			}
			if (y - cy < 0)
				this.contentY = y
			else if (y - cy + ih > h)
				this.contentY = y + ih - h
		}
	}

	focusCurrent: {
		var n = this.count
		if (n == 0)
			return

		var idx = this.currentIndex
		if (idx < 0 || idx >= n) {
			if (this.keyNavigationWraps)
				this.currentIndex = (idx + n) % n
			else
				this.currentIndex = idx < 0? 0: n - 1
			return
		}
		var item = this._items[idx]
		if (item)
			this.focusChild(item)
		if (this.contentFollowsCurrentItem)
			this.positionViewAtIndex(idx)
	}

	onFocusedChildChanged: {
		var idx = this._items.indexOf(this.focusedChild)
		if (idx >= 0)
			this.currentIndex = idx
	}

	onCurrentIndexChanged: {
		this.focusCurrent()
	}

	MouseArea {
		anchors.fill: parent;
		hoverEnabled: parent.dragEnabled;

		checkInnerMouseAreas: {
			var idx = this.parent.indexAt(this.mouseX, this.mouseY)
			for (var i = 0; i < this.parent._items.length; ++i) {
				var isMouseArea = this.parent._items[i] instanceof qml.core.MouseArea
				if (i != idx && isMouseArea && this.parent._items[i].containsMouse) {
					this.parent._items[i].containsMouse = false
					break
				}
			}
			if (this.parent._items[idx] instanceof qml.core.MouseArea)
				this.parent._items[idx].containsMouse = true
		}

		onPressedChanged: {
			if (this.pressed) {
				var idx = this.parent.indexAt(this.mouseX, this.mouseY)
				this._x = this.mouseX
				this._y = this.mouseY
				if (idx >= 0) {
					this.parent.currentIndex = idx
					this.parent.forceActiveFocus()
				}
			}
		}

		onMouseXChanged: {
			this.checkInnerMouseAreas();

			if (!this.pressed)
				return
			var dx = this.mouseX - this._x
			this._x = this.mouseX
			var a = this.parent.getAnimation('contentX')
			if (a)
				a.disable()
			this.parent.move(-dx, 0)
			if (a)
				a.enable()
		}

		onMouseYChanged: {
			this.checkInnerMouseAreas();

			if (!this.pressed)
				return
			var dy = this.mouseY - this._y
			this._y = this.mouseY
			var a = this.parent.getAnimation('contentY')
			if (a)
				a.disable()
			this.parent.move(0, -dy)
			if (a)
				a.enable()
		}

		onVerticalSwiped(event): {
			if (!event)
				return

			var a = this.parent.getAnimation('contentY')
			if (a)
				a.disable()
			this.parent.move(0, -event.dy)
			if (a)
				a.enable()
		}

		onWheelEvent(dp): {
			var horizontal = this.parent.orientation == ListView.Horizontal
			var itemBox = this.parent.getItemPosition(this.parent.currentIndex)
			var iw = itemBox[2], ih = itemBox[3]

			if (horizontal) {
				if (this.parent.contentX <= 0 && dp > 0) {
					this.parent.contentX = 0;
					return;
				}
				if (this.parent.contentX >= (this.parent.contentWidth - this.parent.width) && dp < 0) {
				 	this.parent.contentX = this.parent.contentWidth - this.parent.width;
				 	return;
				}

				if (this.parent.pageScrolling) {
					this.parent.contentX += Math.round(-dp) * this.parent.width;
				}
				else {
					this.parent.contentX += Math.round(-dp) * iw;
				}
			}
			else {
				if (this.parent.contentY <= 0 && dp > 0) {
					this.parent.contentY = 0;
					return;
				}
				if (this.parent.contentY >= (this.parent.contentHeight - this.parent.height) && dp < 0) {
//				 	this.parent.contentY = this.parent.contentHeight - this.parent.height;
				 	return;
				}

				if (this.parent.pageScrolling) {
					this.parent.contentY += Math.round(-dp) * this.parent.height;
				}
				else {
					this.parent.contentY += Math.round(-dp) * ih;
				}
			}
		}

		onClicked: {
			this.parent.clicked();
			if (this.parent._items[this.parent.currentIndex] instanceof qml.core.MouseArea)
				this.parent._items[this.parent.currentIndex].clicked();
		}

		onEntered: {
			this.parent.forceActiveFocus();
			this.parent.focusCurrent()
		}

		z: parent.dragEnabled? parent.z + 1: -1000;
	}

	content: Item {
		Behavior on x	{ Animation { duration: 300; } }
		Behavior on y	{ Animation { duration: 300; } }
		onXChanged:		{ this.parent._layout() }
		onYChanged:		{ this.parent._layout() }
	}

	onContentXChanged: { this.content.x = -value; }
	onContentYChanged: { this.content.y = -value; }

	onRecursiveVisibleChanged: { this._layout() }
	onBoxChanged: { this._layout() }
	onCompleted: { this._attach(); this._layout() }
}
