MouseArea {
	property Object model;
	property Item delegate;

	property int count;
	property int currentIndex;

	property int contentX;
	property int contentY;
	property int contentWidth: 1;
	property int contentHeight: 1;
	property int scrollingStep: 0;
	property int positionMode;

	property bool handleNavigationKeys: true;
	property bool keyNavigationWraps: true;
	property bool contentFollowsCurrentItem: true;
	property bool pageScrolling: false;

	property bool trace;

	hoverEnabled: true;

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
		var center = this.positionMode === this.Center

		if (horizontal) {
			var atCenter = x - w / 2 + iw / 2
			if (center && this.contentWidth > w)
				this.contentX = atCenter < 0 ? 0 : x > this.contentWidth - w / 2 ? this.contentWidth - w : atCenter
			else if (iw > w)
				this.contentX = atCenter
			else if (x - cx < 0)
				this.contentX = x
			else if (x - cx + iw > w)
				this.contentX = x + iw - w
		} else {
			var atCenter = y - h / 2 + ih / 2
			if (center && this.contentHeight > h)
				this.contentY = atCenter < 0 ? 0 : y > this.contentHeight - h / 2 ? this.contentHeight - h : atCenter
			else if (ih > h)
				this.contentY = atCenter
			else if (y - cy < 0)
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

	checkInnerMouseAreas: {
		var idx = this.indexAt(this.mouseX, this.mouseY)
		for (var i = 0; i < this._items.length; ++i) {
			var isMouseArea = this._items[i] instanceof qml.core.MouseArea
			if (i != idx && isMouseArea && this._items[i].containsMouse) {
				this._items[i].containsMouse = false
				break
			}
		}
		if (this._items[idx] instanceof qml.core.MouseArea)
			this._items[idx].containsMouse = true
	}

	onPressedChanged: {
		if (this.pressed) {
			var idx = this.indexAt(this.mouseX, this.mouseY)
			this._x = this.mouseX
			this._y = this.mouseY
			if (idx >= 0) {
				this.currentIndex = idx
				this.forceActiveFocus()
			}
		}
	}

	onMouseXChanged: {
		this.checkInnerMouseAreas();

		if (!this.pressed)
			return
		var dx = this.mouseX - this._x
		this._x = this.mouseX
		var a = this.getAnimation('contentX')
		if (a)
			a.disable()
		this.move(-dx, 0)
		if (a)
			a.enable()
	}

	onMouseYChanged: {
		this.checkInnerMouseAreas();

		if (!this.pressed)
			return
		var dy = this.mouseY - this._y
		this._y = this.mouseY
		var a = this.getAnimation('contentY')
		if (a)
			a.disable()
		this.move(0, -dy)
		if (a)
			a.enable()
	}

	onVerticalSwiped(event): {
		if (!event)
			return

		var a = this.getAnimation('contentY')
		if (a)
			a.disable()
		this.move(0, -event.dy)
		if (a)
			a.enable()
	}

	onWheelEvent(dp): {
		if (this.scrollingStep != 0) {

			if ((this.contentY - this.scrollingStep) <= 0 && dp > 0) {
				this.contentY = 0;
				return;
			}
			if ((this.contentY + this.scrollingStep) >= (this.contentHeight - this.height) && dp < 0) {
				 	this.contentY = this.contentHeight - this.height;
			 	return;
			}
			this.contentY += this.scrollingStep * (-dp);
			return; //TODO: implement all the others
		}

		var horizontal = this.orientation == ListView.Horizontal
		var itemBox = this.getItemPosition(this.currentIndex)
		var iw = itemBox[2], ih = itemBox[3]

		if (horizontal) {
			if (this.contentX <= 0 && dp > 0) {
				this.contentX = 0;
				return;
			}
			if (this.contentX >= (this.contentWidth - this.width) && dp < 0) {
			 	this.contentX = this.contentWidth - this.width;
			 	return;
			}

			if (this.pageScrolling) {
				this.contentX += Math.round(-dp) * this.width;
			}
			else {
				this.contentX += Math.round(-dp) * iw;
			}
		}
		else {
			if (this.contentY <= 0 && dp > 0) {
				this.contentY = 0;
				return;
			}
			if (this.contentY >= (this.contentHeight - this.height) && dp < 0) {
//				 	this.contentY = this.contentHeight - this.height;
			 	return;
			}

			if (this.pageScrolling) {
				this.contentY += Math.round(-dp) * this.height;
			}
			else {
				this.contentY += Math.round(-dp) * ih;
			}
		}
	}

	onClicked: {
		this.currentIndex = this.indexAt(this.mouseX, this.mouseY)
		if (this._items[this.currentIndex] instanceof qml.core.MouseArea) {
			this._items[this.currentIndex].clicked();
		}
	}

	onEntered: {
		this.forceActiveFocus();
		this.focusCurrent()
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
