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

	property bool trace;

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
				console.log(y, ih, h)
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
		//console.log("focused child", this.focusedChild, idx)
		if (idx >= 0)
			this.currentIndex = idx
	}

	onCurrentIndexChanged: {
		this.focusCurrent()
	}

	MouseArea {
		anchors.fill: parent;
		hoverEnabled: parent.dragEnabled;

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

		onWheelEvent(dp): {
			this.parent.currentIndex -= Math.round(dp)
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

	onBoxChanged: { this._layout() }
	onCompleted: { this._attach(); this._layout() }
}
