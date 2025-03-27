///view for displaying models data in grid
BaseView {
	property int cellWidth: 100;	///< grid cell width
	property int cellHeight: 100;	///< grid cell height
	property int rows;				///< grids row count (read only)
	property int columns;			///< grid columns count (read only)
	property enum flow { FlowLeftToRight, FlowTopToBottom };	///< content filling direction

	///@private
	function move(dx, dy) {
		var horizontal = this.flow === this.FlowLeftToRight
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

	///@private
	onKeyPressed: {
		if (!this.handleNavigationKeys)
			return false;

		switch (key) {
			case 'Up': return this.moveUp()
			case 'Down': return this.moveDown()
			case 'Left': return this.moveLeft()
			case 'Right': return this.moveRight()
		}
	}

	onCountChanged: {
		if (value == 0) {
			this.rows = 0
			this.columns = 0
		}
	}

	moveUp: {
		return this.moveCurrentIndex(this.flow === this.FlowLeftToRight? -this.columns: -1)
	}

	moveDown: {
		return this.moveCurrentIndex(this.flow === this.FlowLeftToRight? this.columns: 1)
	}

	moveLeft: {
		return this.moveCurrentIndex(this.flow === this.FlowLeftToRight? -1: -this.rows)
	}

	moveRight: {
		return this.moveCurrentIndex(this.flow === this.FlowLeftToRight? 1: this.rows)
	}

	///@private
	function getItemPosition(idx) {
		var horizontal = this.flow === this.FlowLeftToRight
		var x, y, cw = this.cellWidth, ch = this.cellHeight
		if (horizontal) {
			if (this.columns === 0)
				return [0, 0, 0, 0]
			x = (idx % this.columns) * cw
			y = Math.floor(idx / this.columns) * ch
		} else {
			if (this.rows === 0)
				return [0, 0, 0, 0]
			x = Math.floor(idx / this.rows) * cw
			y = (idx % this.rows) * ch
		}
		return [x, y, cw, ch]
	}

	///@private
	function indexAt(x, y) {
		x -= this.content.x
		y -= this.content.y
		var horizontal = this.flow === this.FlowLeftToRight
		x = Math.floor(x / (this.cellWidth + this.spacing))
		y = Math.floor(y / (this.cellHeight + this.spacing))
		if (!horizontal) {
			return x * this.rows + y
		} else {
			return y * this.columns + x
		}
	}

	///@private
	function positionViewAtIndex(idx) {
		var cx = this.contentX, cy = this.contentY
		var itemBox = this.getItemPosition(idx)
		var x = itemBox[0], y = itemBox[1]
		var iw = itemBox[2], ih = itemBox[3]
		var w = this.width, h = this.height
		var horizontal = this.flow === this.FlowLeftToRight
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

	///@private
	function _layout() {
		if (!this.recursiveVisible && !this.offlineLayout)
			return

		var model = this._modelAttached;
		if (!model) {
			this.layoutFinished()
			return
		}

		this.count = model.count
		if (!this.count) {
			this.layoutFinished()
			return
		}

		var horizontal = this.flow === this.FlowLeftToRight

		var items = this._items
		var padding = this._padding
		var paddingLeft = padding.left || 0, paddingTop = padding.top || 0
		var paddingRight = padding.right || 0, paddingBottom = padding.bottom || 0

		var n = items.length
		var w = this.width - paddingLeft - paddingRight, h = this.height - paddingTop - paddingBottom
		if (this.trace)
			log("layout " + n + " into " + w + "x" + h + " @ " + this.content.x + "," + this.content.y)

		var created = false
		var x = padding.left || 0, y = padding.top || 0
		var cx = this.content.x, cy = this.content.y

		var atEnd = horizontal? function() { return cy + y >= h }: function() { return cx + x >= w }

		var itemsCount = 0
		var cellWidth = this.cellWidth, cellHeight = this.cellHeight
		var stepX = cellWidth + this.spacing, stepY = cellHeight + this.spacing
		for(var i = 0; i < n && !atEnd(); ++i) {
			var item = this._items[i]

			if (!item) {
				item = this._createDelegate(i)
				if (item)
					created = true
			}

			++itemsCount

			if (item) {
				item.viewX = x
				item.viewY = y
			}

			if (item) {
				if (this.currentIndex === i && !item.focused) {
					this.focusChild(item)
					if (this.contentFollowsCurrentItem)
						this.positionViewAtIndex(i)
				}

				var visible = horizontal? (cy + y + item.height >= 0 && cy + y < h): (cx + x + item.width >= 0 && cx + x < w)
				item.visibleInView = visible
			}

			if (horizontal) {
				x += stepX
				if (x > 0 && x + cellWidth > w) {
					x = paddingLeft
					y += stepY
				}
			} else {
				y += stepY
				if (y > 0 && y + cellHeight > h) {
					y = paddingTop
					x += stepX
				}
			}
		}
		for(; i < n; ++i) {
			var item = items[i]
			if (item)
				item.visibleInView = false
		}

		if (!horizontal) {
			this.rows = Math.floor((h + this.spacing) / (this.cellHeight + this.spacing))
			this.columns = Math.floor((n + this.rows - 1) / this.rows)
			this.contentWidth = this.content.width = this.columns * (this.cellWidth + this.spacing) - this.spacing + paddingLeft + paddingRight
			this.contentHeight = this.content.height = this.rows * (this.cellHeight + this.spacing) - this.spacing + paddingTop + paddingBottom
		} else {
			this.columns = Math.floor((w + this.spacing ) / (this.cellWidth + this.spacing))
			this.rows = Math.floor((n + this.columns - 1) / this.columns)
			this.contentWidth = this.content.width = this.columns * (this.cellWidth + this.spacing) - this.spacing + paddingLeft + paddingRight
			this.contentHeight = this.content.height = this.rows * (this.cellHeight + this.spacing) - this.spacing + paddingTop + paddingBottom
		}
		//log(horizontal, w, h, this.rows, this.columns, this.currentIndex, this.contentWidth + "x" + this.contentHeight)
		this.layoutFinished()
	}

	///@private
	function _updateOverflow() {
		if (!this.nativeScrolling) {
			$core.Item.prototype._updateOverflow.apply(this, arguments)
			return
		}

		var horizontal = this.flow !== this.FlowLeftToRight
		var style = {}
		if (horizontal) {
			style['overflow-x'] = 'auto'
			style['overflow-y'] = 'hidden'
		} else {
			style['overflow-x'] = 'hidden'
			style['overflow-y'] = 'auto'
		}
		this.style(style)
	}

	onFlowChanged: {
		this._updateOverflow()
		this._scheduleLayout()
	}

	onNativeScrollingChanged: {
		this._updateOverflow()
	}

	onCellWidthChanged,
	onCellHeightChanged: {
		this._scheduleLayout()
	}

	onCompleted: {
		this._updateOverflow()
	}
}
