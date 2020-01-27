///single direction (vertical or horizontal) oriented view
BaseView {
	property enum orientation { Vertical, Horizontal };	///< orientation direction

	constructor: {
		this._sizes = []
	}

	///@private
	function move(dx, dy) {
		var horizontal = this.orientation === this.Horizontal
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

	///@private
	function positionViewAtIndex(idx) {
		if (this.trace)
			log('positionViewAtIndex ' + idx)
		var horizontal = this.orientation === this.Horizontal
		var itemBox = this.getItemPosition(idx)
		var center = this.positionMode === this.Center

		if (horizontal) {
			this.positionViewAtItemHorizontally(itemBox, center, true)
		} else {
			this.positionViewAtItemVertically(itemBox, center, true)
		}
	}

	///@private
	onKeyPressed: {
		if (!this.handleNavigationKeys) {
			event.accepted = false;
			return false;
		}

		var horizontal = this.orientation === this.Horizontal
		if (horizontal) {
			if (key === 'Left') {
				if (this.currentIndex === 0 && !this.keyNavigationWraps) {
					event.accepted = false;
					return false;
				} else if (this.currentIndex === 0 && this.keyNavigationWraps) {
					this.currentIndex = this.count - 1;
				} else {
					--this.currentIndex;
				}
				event.accepted = true;
				return true;
			} else if (key === 'Right') {
				if (this.currentIndex === this.count - 1 && !this.keyNavigationWraps) {
					event.accepted = false;
					return false;
				} else if (this.currentIndex === this.count - 1 && this.keyNavigationWraps) {
					this.currentIndex = 0;
				} else {
					++this.currentIndex;
				}
				event.accepted = true;
				return true;
			}
		} else {
			if (key === 'Up') {
				if (this.currentIndex === 0 && !this.keyNavigationWraps) {
					event.accepted = false;
					return false;
				} else if (this.currentIndex === 0 && this.keyNavigationWraps) {
					this.currentIndex = this.count - 1;
				} else {
					--this.currentIndex;
				}
				return true;
			} else if (key === 'Down') {
				if (this.currentIndex === this.count - 1 && !this.keyNavigationWraps) {
					event.accepted = false;
					return false;
				} else if (this.currentIndex === this.count - 1 && this.keyNavigationWraps) {
					this.currentIndex = 0;
				} else {
					++this.currentIndex;
				}
				event.accepted = true;
				return true;
			}
		}
	}

	///@private
	function getItemPosition(idx) {
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

	///@private
	function indexAt(x, y) {
		var items = this._items
		x += this.contentX
		y += this.contentY
		if (this.orientation === ListView.Horizontal) {
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

	///@private
	function _layout(noPrerender) {
		var model = this._attached;
		if (!model) {
			this.layoutFinished()
			return
		}

		this.count = model.count

		if (!this.recursiveVisible && !this.offlineLayout) {
			this.layoutFinished()
			return
		}

		var horizontal = this.orientation === this.Horizontal

		var items = this._items
		var sizes = this._sizes
		var n = items.length
		var w = this.width, h = this.height
		var created = false
		var p = 0
		var c = horizontal? this.content.x: this.content.y
		var size = horizontal? w: h
		var maxW = 0, maxH = 0

		var currentIndex = this.currentIndex
		var prerender = noPrerender? 0: this.prerender * size
		var leftMargin = -prerender
		var rightMargin = size + prerender

		if (this.trace)
			log("layout " + n + " into " + w + "x" + h + " @ " + this.content.x + "," + this.content.y + ", prerender: " + prerender + ", range: " + leftMargin + ":" + rightMargin)

		var getItemSize = horizontal?
			function(item) { return item.width }:
			function(item) { return item.height }

		var itemsCount = 0
		var refSize
		for(var i = 0; i < n && (refSize === undefined || p + c < rightMargin); ++i, ++itemsCount) {
			var item = items[i]
			var viewPos = p + c

			var s = sizes[i] || refSize
			if (refSize === undefined && s !== undefined)
				refSize = s

			var renderable = (viewPos + (s !== undefined? s: 0) >= leftMargin && viewPos < rightMargin) || currentIndex === i

			if (!item) {
				//we can render, or no sizes available
				if (renderable || s === undefined) {
					item = this._createDelegate(i)
					created = true
				}
			}

			if (item)
				s = refSize = sizes[i] = getItemSize(item)

			if (item) {
				var visible = (viewPos + s >= 0 && viewPos < size) //checking real delegate visibility, without prerender margin

				if (item.x + item.width > maxW)
					maxW = item.width + item.x
				if (item.y + item.height > maxH)
					maxH = item.height + item.y

				if (horizontal)
					item.viewX = p
				else
					item.viewY = p

				if (currentIndex === i && !item.focused) {
					this.focusChild(item)
					if (this.contentFollowsCurrentItem && this.size)
						this.positionViewAtIndex(i)
				}

				item.visibleInView = visible

				if (!renderable) {
					if (this.trace)
						log('discarding delegate', i)
					this._discardItem(item)
					items[i] = null
					created = true
				}
			} else {
				var nextP = p + refSize
				if (horizontal) {
					if (nextP > maxW)
						maxW = nextP
				} else {
					if (nextP > maxH)
						maxH = nextP
				}
			}

			p += s + this.spacing
		}
		for( ;i < n; ++i) {
			var item = items[i]
			if (item) {
				item.visibleInView = false
				this._discardItem(item)
				items[i] = null
				created = true
			}
		}
		if (p > 0)
			p -= this.spacing;

		if (sizes.length > items.length) {
			///fixme: override model update api to make sizes stable
			sizes = sizes.slice(0, items.length)
		}

		if (itemsCount)
			p *= items.length / itemsCount

		if (this.trace)
			log('result: ' + p + ', max: ' + maxW + 'x' + maxH)
		if (horizontal) {
			this.content.width = p
			this.content.height = maxH
			this.contentWidth = p
			this.contentHeight = maxH
		} else {
			this.content.width = maxW
			this.content.height = p
			this.contentWidth = maxW
			this.contentHeight = p
		}
		this.layoutFinished()
		if (created)
			this._context.scheduleComplete()
	}

	/// @private creates delegate in given item slot
	function _createDelegate(idx) {
		var item = $core.BaseView.prototype._createDelegate.apply(this, arguments)
		//connect both dimensions, because we calculate maxWidth/maxHeight in contentWidth/contentHeight
		item.onChanged('width', this._scheduleLayout.bind(this))
		item.onChanged('height', this._scheduleLayout.bind(this))
		return item
	}

	///@private
	function _updateOverflow() {
		if (!this.nativeScrolling)
			return
		var horizontal = this.orientation === this.Horizontal
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

	///@private
	onOrientationChanged: {
		this._updateOverflow()
		this._scheduleLayout()
		this._sizes = []
	}

	onCompleted: {
		this._updateOverflow()
	}
}
