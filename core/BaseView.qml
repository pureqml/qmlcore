Item {
	property Object model;
	property Item delegate;

	property int count;
	property int currentIndex;

	property int contentX;
	property int contentY;
	property alias contentWidth: content.width;
	property alias contentHeight: content.height;

	property bool handleNavigationKeys: true;
	property bool keyNavigationWraps: true;
	property bool dragEnabled: true;

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
			if (x - cx < 0)
				this.contentX = x
			else if (x - cx + iw > w)
				this.contentX = x + iw - w
		} else {
			if (y - cy < 0)
				this.contentY = y
			else if (y - cy + ih > h)
				this.contentY = y + ih - h
		}
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
				if (idx >= 0)
					this.parent.currentIndex = idx
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
	onCompleted: { this._layout() }
}
