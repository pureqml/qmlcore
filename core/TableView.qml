BaseView {
	property int columns;
	property int rowSpacing;
	property int columnSpacing;

	property int referenceWidth: 90; ///< @internal
	property int referenceHeight: 60; ///< @internal

	constructor: {
		this._hsizes = []
		this._vsizes = []
		this._scrollDeltaX = 0
		this._scrollDeltaY = 0
	}

	function _getTablePosition(idx) {
		var columns = this.columns
		if (columns <= 0)
			return [0, 0]

		var n = this._items.length
		var row = Math.floor(idx / columns)
		var rows = Math.floor((n + columns - 1) / columns)
		var column = idx % columns
		return [row, column, rows]
	}

	function _invalidateSize(idx) {
		var pos = this._getTablePosition(idx)
		var row = pos[0]
		var column = pos[1]
		this._hsizes[column] = this._vsizes[row] = undefined
		this._scheduleLayout()
	}

	function _createDelegate(idx) {
		var item = $core.BaseView.prototype._createDelegate.apply(this, arguments)

		var updateX = function() {
			this._invalidateSize(idx)
			if (this.nativeScrolling) {
				//if delegate updates its width and it's on the left/top of scrolling position
				//it will cause annoying jumps
				if (item.viewX < this.element.getScrollX()) {
					this._scrollDeltaX += item.width - (this._hsizes[idx] || this.referenceWidth)
				}
			}
		}

		var updateY = function() {
			this._invalidateSize(idx)
			if (this.nativeScrolling) {
				if (item.viewY < this.element.getScrollY()) {
					this._scrollDeltaY += item.height - (this._vsizes[idx] || this.referenceHeight)
				}
			}
		}
		this.connectOnChanged(item, 'width', updateX.bind(this), true) //skip initial update
		this.connectOnChanged(item, 'height', updateY.bind(this), true) //skip initial update
		return item
	}

	/// @private
	function _layout(noPrerender) {
		if (!this.recursiveVisible && !this.offlineLayout)
			return

		var model = this._modelAttached;
		if (!model) {
			this.layoutFinished()
			return
		}

		this.count = model.count
		if (!this.count || this.columns <= 0) {
			this.layoutFinished()
			return
		}

		var padding = this._padding
		var paddingLeft = padding.left || 0, paddingTop = padding.top || 0
		var items = this._items
		var sizes = this._sizes
		var n = items.length
		var width = this.width - paddingLeft - (padding.right || 0)
		var height = this.height - paddingTop - (padding.bottom || 0)
		var created = false

		var currentIndex = this.currentIndex
		var discardDelegates = !noPrerender
		var prerenderW = noPrerender? 0: this.prerender * this.width
		var prerenderH = noPrerender? 0: this.prerender * this.height
		var leftMargin = -prerenderW, topMargin = -prerenderH
		var rightMargin = width + prerenderW, bottomMargin = height + prerenderH
		var refWidth = this.referenceWidth, refHeight = this.referenceHeight
		var columns = this.columns
		var rows = Math.floor((n + columns - 1) / columns)
		var vsizes = this._vsizes
		var hsizes = this._hsizes
		var rowSpacing = this.rowSpacing
		var columnSpacing = this.columnSpacing
		var contentX = this.content.x
		var contentY = this.content.y

		if (this._scrollDeltaX != 0) {
			if (this.nativeScrolling) {
				this.element.setScrollX(this.element.getScrollX() - this._scrollDeltaX)
			}
			this._scrollDeltaX = 0
		}
		if (this._scrollDeltaY != 0) {
			if (this.nativeScrolling) {
				this.element.setScrollY(this.element.getScrollY() - this._scrollDeltaY)
			}
			this._scrollDeltaY = 0
		}

		if (this.trace)
			log("layout " + n + "(" + rows + "x" + columns + ") into " + width + "x" + height + " @ " + this.content.x + "," + this.content.y + ", prerender: " + prerenderW + "," + prerenderH + ", range: " + leftMargin + "," + topMargin + "," + rightMargin + "," + bottomMargin)

		//first pass - create delegates they can only extend atm
		var xp = 0
		var yp = 0
		var row = 0
		var column = 0

		for(var i = 0; i < n; ++i, ++column) {
			if (column >= columns) {
				column = 0
				xp = 0

				var rowHeight = vsizes[row]
				if (!rowHeight)
					rowHeight = refHeight

				yp += rowHeight + rowSpacing
				++row
			}

			var item = items[i]
			var renderable = (xp + contentX) >= leftMargin && (yp + contentY) >= topMargin && (xp + contentX) < rightMargin && (yp + contentY) < bottomMargin

			if (renderable && !item) {
				item = this._createDelegate(i)
				created = true

				if (currentIndex === i && !item.focused) {
					this.focusChild(item)
					if (this.contentFollowsCurrentItem)
						this.positionViewAtIndex(i)
				}
			}

			if (item) {
				if (!hsizes[column])
					hsizes[column] = item.width
				else
					hsizes[column] = Math.max(hsizes[column], item.width)

				if (!vsizes[row])
					vsizes[row] = item.height
				else
					vsizes[row] = Math.max(vsizes[row], item.height)
			}

			var colWidth = hsizes[column]
			if (colWidth === undefined)
				colWidth = refWidth

			xp += colWidth + columnSpacing
		}

		var contentWidth = 0
		xp = 0
		yp = 0
		row = 0
		column = 0

		for(var i = 0; i < n; ++i, ++column) {
			if (column >= columns) {
				column = 0
				xp = 0

				var rowHeight = vsizes[row]
				if (!rowHeight)
					rowHeight = refHeight
				yp += rowHeight + rowSpacing

				++row
			}

			var item = items[i]
			var renderable = (xp + contentX) >= leftMargin && (yp + contentY) >= topMargin && (xp + contentX) < rightMargin && (yp + contentY) < bottomMargin

			if (item) {
				item.viewX = xp
				item.viewY = yp
			}

			var colWidth = hsizes[column]
			if (colWidth === undefined)
				colWidth = refWidth

			if (discardDelegates && !renderable && item) {
				if (this.trace)
					log('discarding delegate', i)
				this._discardItem(item)
				items[i] = null
				created = true
			}

			xp += colWidth + columnSpacing
			if (xp > contentWidth)
				contentWidth = xp
		}

		contentWidth -= columnSpacing
		yp += rowHeight

		this.contentWidth = contentWidth
		this.content.width = contentWidth
		this.contentHeight = yp
		this.content.height = yp
		if (this.trace)
			log("content size", this.contentWidth, this.contentHeight)

		this.layoutFinished()
	}

	onKeyPressed: {
		if (!this.handleNavigationKeys) {
			return false
		}

		var columns = this.columns
		var count = this.count
		if (columns <= 0 || count <= 0) {
			return false
		}

		var pos = this._getTablePosition(this.currentIndex)
		var row = pos[0]
		var column = pos[1]
		var rows = pos[2]

		if (key === 'Left') {
			if (this.keyNavigationWraps) {
				if (column === 0)
					this.currentIndex += columns - 1
				else
					--this.currentIndex
			} else {
				if (column > 0)
					--this.currentIndex
			}
			return true
		} else if (key === 'Right') {
			if (this.keyNavigationWraps) {
				if (column == columns - 1)
					this.currentIndex -= columns - 1
				else
					++this.currentIndex
			} else {
				if (column < columns - 1)
					++this.currentIndex
			}
			return true
		} else if (key === 'Up') {
			if (this.keyNavigationWraps) {
				if (row === 0)
					this.currentIndex += count - columns
				else
					this.currentIndex -= columns
			} else {
				if (row > 0)
					this.currentIndex -= columns
			}
			return true
		} else if (key === 'Down') {
			if (this.keyNavigationWraps) {
				if (row === rows - 1)
					this.currentIndex -= count - columns
				else
					this.currentIndex += columns
			} else {
				if (row < rows - 1)
					this.currentIndex += columns
			}
			return true
		}
	}

	function getItemPosition(idx) {
		var items = this._items
		var item = items[idx]
		if (!item) {
			var vsizes = this._vsizes
			var hsizes = this._hsizes
			var pos = this._getTablePosition(idx)
			var row = pos[0], column = pos[1]
			var y = 0, x = 0
			for(var i = 0; i < row; ++i)
				y += vsizes[i]
			for(var i = 0; i < column; ++i)
				x += hsizes[i]
			return [x, y, hsizes[column] || this.referenceWidth, vsizes[row] || this.referenceHeight]
		}
		else
			return [item.viewX + item.x, item.viewY + item.y, item.width, item.height]
	}

	///@private
	function positionViewAtIndex(idx) {
		if (this.trace)
			log('positionViewAtIndex ' + idx)

		var itemBox = this.getItemPosition(idx)
		var center = this.positionMode === this.Center

		this.positionViewAtItemHorizontally(itemBox, center, true)
		this.positionViewAtItemVertically(itemBox, center, true)
	}

	function indexAt(x, y) {
		var items = this._items
		var columns = this.columns
		if (columns <= 0)
			return -1

		var vsizes = this._vsizes
		var hsizes = this._hsizes

		x += this.contentX
		y += this.contentY
		if (x < 0 || y < 0)
			return -1

		var rows = Math.floor((this.count + columns - 1) / columns)
		var row, column
		for(row = 0; row < rows; ++row) {
			var h = vsizes[row] || this.referenceHeight
			if (y < h)
				break
			y -= h
		}
		for(column = 0; column < columns; ++column) {
			var w = hsizes[column] || this.referenceWidth
			if (x < w)
				break
			x -= w
		}
		return column + row * columns
	}

	///@private
	function _updateOverflow() {
		if (!this.nativeScrolling) {
			$core.Item.prototype._updateOverflow.apply(this, arguments)
			return
		}

		var style = {}
		style['overflow'] = 'auto'
		this.style(style)
	}

	onColumnsChanged: {
		this._scheduleLayout()
	}

	onNativeScrollingChanged: {
		this._updateOverflow()
	}

	onCompleted: {
		this._updateOverflow()
	}
}
