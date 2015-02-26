Item {
	property Object model;
	property Item delegate;

	property int orientation;
	property int spacing;

	property int count;
	property int currentIndex;

	property int contentX;
	property int contentY;
	property int contentWidth;
	property int contentHeight;

	property bool handleNavigationKeys: true;
	property bool keyNavigationWraps: true;
	property bool dragEnabled: true;

	Behavior on contentX	{ Animation { duration: 300; } }
	Behavior on contentY	{ Animation { duration: 300; } }

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
			if (!this.pressed || this.parent.orientation != ListView.Horizontal)
				return
			var dx = this.mouseX - this._x
			this._x = this.mouseX
			var a = this.parent.getAnimation('contentX')
			if (a)
				a.disable()
			this.parent.contentX -= dx
			if (a)
				a.enable()
		}

		onMouseYChanged: {
			if (!this.pressed || this.parent.orientation != ListView.Vertical)
				return
			var dy = this.mouseY - this._y
			this._y = this.mouseY
			var a = this.parent.getAnimation('contentY')
			if (a)
				a.disable()
			this.parent.contentY -= dy
			if (a)
				a.enable()
		}

		onWheelEvent(dp): {
			this.parent.currentIndex -= Math.round(dp)
		}

		z: parent.dragEnabled? parent.z + 1: -1000;
	}

	onKeyPressed: {
		var horizontal = this.orientation == this.Horizontal
		if (horizontal) {
			if (key == 'Left')
				--this.currentIndex;
			else if (key == 'Right')
				++this.currentIndex;
		} else {
			if (key == 'Up')
				--this.currentIndex;
			else if (key == 'Down')
				++this.currentIndex;
		}
	}

	getItemPosition(idx): {
		var cx = this.contentX, cy = this.contentY
		var items = this._items
		var item = items[idx]
		if (!item) {
			var x = 0, y = 0, w = 0, h = 0
			for(var i = idx; i >= 0; --i) {
				if (items[i]) {
					item = items[i]
					x = item.viewX + item.x + cx
					y = item.viewY + item.y + cy
					w = item.width
					h = item.height
					break
				}
			}
			var missing = idx - i
			if (missing > 0) {
				x += missing * (w + this.spacing)
				y += missing * (h + this.spacing)
			}
			return [x, y, w, h]
		}
		else
			return [item.viewX + item.x + cx, item.viewY + item.y + cy, item.width, item.height]
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
		this.positionViewAtIndex(idx)
		if (item)
			this.focusChild(item)
	}

	indexAt(x, y): {
		var items = this._items
		if (this.orientation == ListView.Horizontal) {
			for (var i = 0; i < items.length; ++i) {
				var item = items[i]
				if (!item)
					continue
				var vx = item.viewX
				if (x >= vx && x < vx + item.width)
					return i
			}
		} else {
			for (var i = 0; i < items.length; ++i) {
				var item = items[i]
				if (!item)
					continue
				var vy = item.viewY
				if (y >= vy && y < vy + item.height)
					return i
			}
		}
		return -1
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
}
