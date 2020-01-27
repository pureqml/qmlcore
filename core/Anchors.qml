///Anchors, generic class to handle auto-adjusting positioning, used in Item
Object {
	property AnchorLine bottom;				///< bottom anchor line
	property AnchorLine verticalCenter;		///< target for vertical center
	property AnchorLine top;				///< top anchor line

	property AnchorLine left;				///< left anchor line
	property AnchorLine horizontalCenter;	///< target for horizontal center
	property AnchorLine right;				///< right anchor line

	property Item fill;		///< target to fill
	property Item centerIn;	///< target to place in center of it

	property int margins;		///< set all margins to same value
	property int bottomMargin;	///< bottom margin value
	property int topMargin;		///< top margin value
	property int leftMargin;	///< left margin value
	property int rightMargin;	///< right margin value

	constructor : {
		this._items = []
		this._grabX = false
		this._grabY = false
	}

	function _scheduleUpdate() {
		this._context.delayedAction('update-anchors', this, this._updateAll)
	}

	function _grab(item, prop) {
		if (prop === 'x')
			this._grabX = true
		if (prop === 'y')
			this._grabY = true
		item._removeUpdater(prop)
	}

	function _getAnchor(name) {
		var value = this[name]
		return value? Array.isArray(value)? value: value[name]: null
	}

	/** @private */
	function _updateAll() {
		var anchors = this
		var item = anchors.parent
		if (item === null) //disposed
			return
		var parent = item.parent

		var parent_box = parent.toScreen()
		var parentX = parent_box[0], parentY = parent_box[1]

		var fill = anchors.fill
		var leftAnchor = anchors._getAnchor('left') || (fill? fill.left: null)
		var rightAnchor = anchors._getAnchor('right') || (fill? fill.right: null)
		var topAnchor = anchors._getAnchor('top') || (fill? fill.top: null)
		var bottomAnchor = anchors._getAnchor('bottom') || (fill? fill.bottom: null)

		var centerIn = anchors.centerIn
		var hcenterAnchor = anchors._getAnchor('horizontalCenter') || (centerIn? centerIn.horizontalCenter: null)
		var vcenterAnchor = anchors._getAnchor('verticalCenter') || (centerIn? centerIn.verticalCenter: null)

		var lm = anchors.leftMargin || anchors.margins
		var rm = anchors.rightMargin || anchors.margins
		var tm = anchors.topMargin || anchors.margins
		var bm = anchors.bottomMargin || anchors.margins

		var cacheObjects = []
		var cachePositions = []

		var toScreen = function(line) {
			var object = line[0], index = line[1]
			var objectIdx = cacheObjects.indexOf(object)
			var screenPos
			if (objectIdx < 0) {
				screenPos = object.toScreen()
				cacheObjects.push(object)
				cachePositions.push(screenPos)
			}
			else
				screenPos = cachePositions[objectIdx]
			return screenPos[index]
		}

		var left, top, right, bottom, hcenter, vcenter
		if (leftAnchor && rightAnchor) {
			left = toScreen(leftAnchor)
			right = toScreen(rightAnchor)
			item.x = left + lm - parentX - item.viewX
			item.width = right - left - rm - lm
		} else if (leftAnchor && hcenterAnchor) {
			left = toScreen(leftAnchor)
			hcenter = toScreen(hcenterAnchor);
			item.x = left + lm - parentX - item.viewX
			item.width = (hcenter - left) * 2 - rm - lm
		} else if (hcenterAnchor && rightAnchor) {
			hcenter = toScreen(hcenterAnchor);
			right = toScreen(rightAnchor)
			item.width = (right - hcenter) * 2 - rm - lm
			item.x = hcenter - (item.width + lm - rm) / 2 - parentX - item.viewX
		} else if (leftAnchor) {
			left = toScreen(leftAnchor)
			item.x = left + lm - parentX - item.viewX
		} else if (rightAnchor) {
			right = toScreen(rightAnchor)
			item.x = right - parentX - rm - item.width - item.viewX
		} else if (hcenterAnchor) {
			hcenter = toScreen(hcenterAnchor)
			item.x = hcenter - (item.width + lm - rm) / 2 - parentX - item.viewX
		} else if (this._grabX)
			item.x = lm

		if (topAnchor && bottomAnchor) {
			top = toScreen(topAnchor)
			bottom = toScreen(bottomAnchor)
			item.y = top + tm - parentY - item.viewY
			item.height = bottom - top - bm - tm
		} else if (topAnchor && vcenterAnchor) {
			top = toScreen(topAnchor)
			vcenter = toScreen(vcenterAnchor)
			item.y = top + tm - parentY - item.viewY
			item.height = (vcenter - top) * 2 - bm - tm
		} else if (vcenterAnchor && bottomAnchor) {
			vcenter = toScreen(vcenterAnchor)
			bottom = toScreen(bottomAnchor)
			item.height = (bottom - vcenter) * 2 - bm - tm
			item.y = vcenter - (item.height + tm - bm) / 2 - parentY - item.viewY
		} else if (topAnchor) {
			top = toScreen(topAnchor)
			item.y = top + tm - parentY - item.viewY
		} else if (bottomAnchor) {
			bottom = toScreen(bottomAnchor)
			item.y = bottom - parentY - bm - item.height - item.viewY
		} else if (vcenterAnchor) {
			vcenter = toScreen(vcenterAnchor)
			item.y = vcenter - (item.height + tm - bm) / 2 - parentY - item.viewY
		} else if (this._grabY)
			item.y = tm
	}

	/** @private */
	function _subscribe(src) {
		var items = this._items
		//connect only once per item
		if (items.indexOf(src) < 0) {
			items.push(src)
			this.connectOn(src, 'newBoundingBox', this._scheduleUpdate.bind(this))
		}
	}

	onLeftChanged: {
		this._scheduleUpdate()
		var left = this._getAnchor('left')
		if (left === null)
			return

		var item = this.parent
		var anchors = this
		this._grab(item, 'x')
		if (anchors.right || anchors.horizontalCenter) {
			this._grab(item, 'width')
			this._subscribe(item)
		}
		this._subscribe(left[0])
	}

	onRightChanged: {
		this._scheduleUpdate()
		var right = this._getAnchor('right')
		if (right === null)
			return

		var item = this.parent
		var anchors = this
		this._grab(item, 'x')
		if (anchors.left || anchors.horizontalCenter) {
			this._grab(item, 'width')
		}
		this._subscribe(item)
		this._subscribe(right[0])
	}

	onHorizontalCenterChanged: {
		this._scheduleUpdate()
		var hc = this._getAnchor('horizontalCenter')
		if (hc === null)
			return

		var item = this.parent
		var anchors = this
		this._grab(item, 'x')
		if (anchors.left || anchors.right) {
			this._grab(item, 'width')
		}
		this._subscribe(item)
		this._subscribe(hc[0])
	}

	onTopChanged: {
		this._scheduleUpdate()
		var top = this._getAnchor('top')
		if (top === null)
			return

		var item = this.parent
		var anchors = this
		this._grab(item, 'y')
		if (anchors.bottom || anchors.verticalCenter) {
			this._grab(item, 'height')
			this._subscribe(item)
		}
		this._subscribe(top[0])
	}

	onBottomChanged: {
		this._scheduleUpdate()
		var bottom = this._getAnchor('bottom')
		if (bottom === null)
			return

		var item = this.parent
		var anchors = this
		this._grab(item, 'y')
		if (anchors.top || anchors.verticalCenter) {
			this._grab(item, 'height')
		}
		this._subscribe(item)
		this._subscribe(bottom[0])
	}

	onVerticalCenterChanged: {
		this._scheduleUpdate()
		var vc = this._getAnchor('verticalCenter')
		if (vc === null)
			return

		var item = this.parent
		var anchors = this
		this._grab(item, 'y')
		if (anchors.top || anchors.bottom) {
			this._grab(item, 'height')
		}
		this._subscribe(item)
		this._subscribe(vc[0])
	}

	onFillChanged: {
		this._scheduleUpdate()
		if (value === null)
			return

		var item = this.parent
		var anchors = this
		this._grab(item, 'x')
		this._grab(item, 'width')
		this._grab(item, 'y')
		this._grab(item, 'height')
		this._subscribe(value)
	}

	onCenterInChanged: {
		this._scheduleUpdate()
		if (value === null)
			return

		var item = this.parent
		var anchors = this
		this._grab(item, 'x')
		this._grab(item, 'y')
		this._subscribe(value)
		this._subscribe(item)
	}

	onLeftMarginChanged,
	onRightMarginChanged,
	onTopMarginChanged,
	onBottomMarginChanged,
	onMarginChanged:		{ this.parent.anchorsMarginsUpdated(); this._scheduleUpdate(); }
}
