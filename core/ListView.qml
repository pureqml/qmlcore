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

	Behavior on contentX	{ Animation { duration: 300; } }
	Behavior on contentY	{ Animation { duration: 300; } }

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

	positionViewAtIndex(idx): {
		var item = this._items[idx]
		if (!item)
			return

		var cx = this.contentX, cy = this.contentY
		var x = item.viewX + item.x + cx, y = item.viewY + item.y + cy
		var w = this.width, h = this.height
		var horizontal = this.orientation == this.Horizontal
		if (horizontal) {
			if (x - cx < 0)
				this.contentX = x
			else if (x - cx + item.width > w)
				this.contentX = x + item.width - w
		} else {
			if (y - cy < 0)
				this.contentY = y
			else if (y - cy + item.height > h)
				this.contentY = y + item.height - h
		}
	}

	focusCurrent: {
		var n = this.count
		if (n == 0)
			return
		var idx = this.currentIndex
		if (idx < 0 || idx >= n) {
			this.currentIndex = (idx + n) % n
			return
		}
		var item = this._items[idx]
		if (item) {
			this.focusChild(item)
			this.positionViewAtIndex(idx)
		}
	}

	onCurrentIndexChanged: {
		this.focusCurrent()
	}
}
