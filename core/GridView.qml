BaseView {
	property int flow;

	property int cellWidth: 100;
	property int cellHeight: 100;

	property int rows;
	property int columns;

	move(dx, dy): {
		var horizontal = this.flow == this.FlowLeftToRight
		if (horizontal)
			this.contentX += dx
		else
			this.contentY += dy
	}

	onKeyPressed: {
		var horizontal = this.flow == this.FlowLeftToRight
		if (horizontal) {
			switch(key) {
				case 'Up':		--this.currentIndex; return true;
				case 'Down':	++this.currentIndex; return true
				case 'Left':	this.currentIndex -= this.rows; return true
				case 'Right':	this.currentIndex += this.rows; return true
			}
		} else {
			switch(key) {
				case 'Left':	--this.currentIndex; return true
				case 'Right':	++this.currentIndex; return true
				case 'Up':		this.currentIndex -= this.columns; return true
				case 'Down':	this.currentIndex += this.columns; return true
			}
		}
	}

	getItemPosition(idx): {
		var horizontal = this.flow == this.FlowLeftToRight
		var x, y, cw = this.cellWidth, ch = this.cellHeight
		if (horizontal) {
			if (this.rows == 0)
				return [0, 0, 0, 0]
			x = Math.floor(idx / this.rows) * cw
			y = (idx % this.rows) * ch
		} else {
			if (this.rows == 0)
				return [0, 0, 0, 0]
			x = Math.floor(idx / this.columns) * cw
			y = (idx % this.columns) * ch
		}
		return [x, y, cw, ch]
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
		x -= this.content.x
		y -= this.content.y
		var horizontal = this.flow == this.FlowLeftToRight
		x = Math.floor(x / this.cellWidth)
		y = Math.floor(y / this.cellHeight)
		if (horizontal) {
			return x * this.rows + y
		} else {
			return y * this.columns + x
		}
		return -1
	}

	onFlowChanged: { this._layout() }
}
