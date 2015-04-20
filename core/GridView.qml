BaseView {
	property int flow;

	property int cellWidth: 100;
	property int cellHeight: 100;

	property int rows;
	property int columns;

	move(dx, dy): {
		var horizontal = this.flow == this.FlowLeftToRight
		var x, y
		if (horizontal && this.contentHeight > this.height) {
			y = this.contentY + dy
			if (y < 0)
				y = 0
			else if (y > this.contentHeight - this.height)
				y = this.contentHeight - this.height
			this.contentY = y
		} else if (!horizontal && this.contentWidth > this.width) {
			x = this.contentX + dx
			if (x < 0)
				x = 0
			else if (x > this.contentWidth - this.width)
				x = this.contentWidth - this.width
			this.contentX = x
		}
	}

	onKeyPressed: {
		if (!this.handleNavigationKeys)
			return false;

		var horizontal = this.flow == this.FlowLeftToRight
		if (horizontal) {
			switch(key) {
				case 'Left':	--this.currentIndex; return true
				case 'Right':	++this.currentIndex; return true
				case 'Up':		this.currentIndex -= this.columns; return true
				case 'Down':	this.currentIndex += this.columns; return true
			}
		} else {
			switch(key) {
				case 'Up':		--this.currentIndex; return true;
				case 'Down':	++this.currentIndex; return true
				case 'Left':	this.currentIndex -= this.rows; return true
				case 'Right':	this.currentIndex += this.rows; return true
			}
		}
	}

	getItemPosition(idx): {
		var horizontal = this.flow == this.FlowLeftToRight
		var x, y, cw = this.cellWidth, ch = this.cellHeight
		if (horizontal) {
			if (this.columns == 0)
				return [0, 0, 0, 0]
			x = (idx % this.columns) * cw
			y = Math.floor(idx / this.columns) * ch
		} else {
			if (this.rows == 0)
				return [0, 0, 0, 0]
			x = Math.floor(idx / this.rows) * cw
			y = (idx % this.rows) * ch
		}
		return [x, y, cw, ch]
	}

	indexAt(x, y): {
		var items = this._items
		x -= this.content.x
		y -= this.content.y
		var horizontal = this.flow == this.FlowLeftToRight
		x = Math.floor(x / this.cellWidth)
		y = Math.floor(y / this.cellHeight)
		if (!horizontal) {
			return x * this.rows + y
		} else {
			return y * this.columns + x
		}
	}

	positionViewAtIndex(idx): {
		var cx = this.contentX, cy = this.contentY
		var itemBox = this.getItemPosition(idx)
		var x = itemBox[0], y = itemBox[1]
		var iw = itemBox[2], ih = itemBox[3]
		var w = this.width, h = this.height
		var horizontal = this.flow == this.FlowLeftToRight
		if (!horizontal) {
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

	onFlowChanged: { this._layout() }
}
