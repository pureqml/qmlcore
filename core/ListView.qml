BaseView {
	property int orientation;
	property int spacing;

	move(dx, dy): {
		var horizontal = this.orientation == this.Horizontal
		var x, y
		if (horizontal && this.contentWidth > this.width) {
			x = this.contentX + dx
			if (x < 0)
				x = 0
			else if (x > this.contentWidth - this.width)
				x = this.contentWidth - this.width
			this.contentX = x
		} else if (!horizontal && this.contentHeight > this.height) {
			y = this.contentY + dy
			if (y < 0)
				y = 0
			else if (y > this.contentHeight - this.height)
				y = this.contentHeight - this.height
			this.contentY = y
		}
	}

	onKeyPressed: {
		if (!this.handleNavigationKeys) {
			event.accepted = false;
			return false;
		}

		var horizontal = this.orientation == this.Horizontal
		if (horizontal) {
			if (key == 'Left') {
				--this.currentIndex;
				event.accepted = true;
				return true;
			} else if (key == 'Right') {
				++this.currentIndex;
				event.accepted = true;
				return true;
			}
		} else {
			if (key == 'Up') {
				if (!this.currentIndex && !this.keyNavigationWraps) {
					event.accepted = false;
					return false;
				}
				--this.currentIndex;
				return true;
			} else if (key == 'Down') {
				if (this.currentIndex == this.count - 1 && !this.keyNavigationWraps) {
					event.accepted = false;
					return false;
				}
				++this.currentIndex;
				event.accepted = true;
				return true;
			}
		}
	}

	getItemPosition(idx): {
		var items = this._items
		var item = items[idx]
		if (!item) {
			var x = 0, y = 0, w = 0, h = 0
			for(var i = idx; i >= 0; --i) {
				if (items[i]) {
					item = items[i]
					x = item.viewX + item.x
					y = item.viewY + item.y
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
			return [item.viewX + item.x, item.viewY + item.y, item.width, item.height]
	}

	indexAt(x, y): {
		var items = this._items
		var center = this.positionMode === this.Center
		x += this.contentX
		y += this.contentY
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
	onOrientationChanged: { this._layout() }
}
