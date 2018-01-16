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

	signal marginsUpdated;		///< @private

	constructor : {
		this._items = []
		this._boundUpdateAll = this._updateAll.bind(this)
	}

	/** @private */
	function _updateAll() {
		var anchors = this
		var item = anchors.parent
		var parent = item.parent

		var parent_box = parent.toScreen()
		var parentX = parent_box[0], parentY = parent_box[1]

		var fill = anchors.fill
		var leftAnchor = anchors.left || (fill? fill.left: null)
		var rightAnchor = anchors.right || (fill? fill.right: null)
		var topAnchor = anchors.top || (fill? fill.top: null)
		var bottomAnchor = anchors.bottom || (fill? fill.bottom: null)

		var centerIn = anchors.centerIn
		var hcenterAnchor = anchors.horizontalCenter || (centerIn? centerIn.horizontalCenter: null)
		var vcenterAnchor = anchors.verticalCenter || (centerIn? centerIn.verticalCenter: null)

		var lm = anchors.leftMargin || anchors.margins
		var rm = anchors.rightMargin || anchors.margins
		var tm = anchors.topMargin || anchors.margins
		var bm = anchors.bottomMargin || anchors.margins

		var left, top, right, bottom, hcenter, vcenter
		if (leftAnchor && rightAnchor) {
			left = leftAnchor.toScreen()
			right = rightAnchor.toScreen()
			item.x = left + lm - parentX - item.viewX
			item.width = right - left - rm - lm
		} else if (leftAnchor && hcenterAnchor) {
			left = leftAnchor.toScreen()
			hcenter = hcenterAnchor.toScreen();
			item.x = left + lm - parentX - item.viewX
			item.width = (hcenter - left) * 2 - rm - lm
		} else if (hcenterAnchor && rightAnchor) {
			hcenter = hcenterAnchor.toScreen();
			right = rightAnchor.toScreen()
			item.width = (right - hcenter) * 2 - rm - lm
			item.x = hcenter - (item.width + lm - rm) / 2 - parentX - item.viewX
		} else if (leftAnchor) {
			left = leftAnchor.toScreen()
			item.x = left + lm - parentX - item.viewX
		} else if (rightAnchor) {
			right = rightAnchor.toScreen()
			item.x = right - parentX - rm - item.width - item.viewX
		} else if (hcenterAnchor) {
			hcenter = hcenterAnchor.toScreen()
			item.x = hcenter - (item.width + lm - rm) / 2 - parentX - item.viewX
		}

		if (topAnchor && bottomAnchor) {
			top = topAnchor.toScreen()
			bottom = bottomAnchor.toScreen()
			item.y = top + tm - parentY - item.viewY
			item.height = bottom - top - bm - tm
		} else if (topAnchor && vcenterAnchor) {
			top = topAnchor.toScreen()
			vcenter = vcenterAnchor.toScreen()
			item.y = top + tm - parentY - item.viewY
			item.height = (vcenter - top) * 2 - bm - tm
		} else if (vcenterAnchor && bottomAnchor) {
			vcenter = vcenterAnchor.toScreen()
			bottom = bottomAnchor.toScreen()
			item.height = (bottom - vcenter) * 2 - bm - tm
			item.y = vcenter - (item.height + tm - bm) / 2 - parentY - item.viewY
		} else if (topAnchor) {
			top = topAnchor.toScreen()
			item.y = top + tm - parentY - item.viewY
		} else if (bottomAnchor) {
			bottom = bottomAnchor.toScreen()
			item.y = bottom - parentY - bm - item.height - item.viewY
		} else if (vcenterAnchor) {
			vcenter = vcenterAnchor.toScreen()
			item.y = vcenter - (item.height + tm - bm) / 2 - parentY - item.viewY
		}
	}

	/** @private */
	function _subscribe(src) {
		var items = this._items
		//connect only once per item
		if (items.indexOf(src) < 0) {
			items.push(src)
			this.connectOn(src, 'boxChanged', this._boundUpdateAll)
		}
	}

	onLeftChanged: {
		var item = this.parent
		var anchors = this
		item._removeUpdater('x')
		if (anchors.right || anchors.horizontalCenter) {
			item._removeUpdater('width')
			this._subscribe(item)
		}
		this._subscribe(value.parent)
		this._updateAll()
	}

	onRightChanged: {
		var item = this.parent
		var anchors = this
		item._removeUpdater('x')
		if (anchors.left || anchors.horizontalCenter) {
			anchors._removeUpdater('width')
		}
		this._subscribe(item)
		this._subscribe(value.parent)
		this._updateAll()
	}

	onHorizontalCenterChanged: {
		var item = this.parent
		var anchors = this
		item._removeUpdater('x')
		if (anchors.left || anchors.right) {
			anchors._removeUpdater('width')
		}
		this._subscribe(item)
		this._subscribe(value.parent)
		this._updateAll()

	}
	onTopChanged: {
		var item = this.parent
		var anchors = this
		item._removeUpdater('y')
		if (anchors.bottom || anchors.verticalCenter) {
			item._removeUpdater('height')
			this._subscribe(item)
		}
		this._subscribe(value.parent)
		this._updateAll()

	}
	onBottomChanged: {
		var item = this.parent
		var anchors = this
		item._removeUpdater('y')
		if (anchors.top || anchors.verticalCenter) {
			item._removeUpdater('height')
		}
		this._subscribe(item)
		this._subscribe(value.parent)
		this._updateAll()
	}

	onVerticalCenterChanged: {
		var item = this.parent
		var anchors = this
		item._removeUpdater('y')
		if (anchors.top || anchors.bottom) {
			item._removeUpdater('height')
		}
		this._subscribe(item)
		this._subscribe(value.parent)
		this._updateAll()
	}

	onFillChanged: {
		var item = this.parent
		var anchors = this
		item._removeUpdater('x')
		item._removeUpdater('width')
		item._removeUpdater('y')
		item._removeUpdater('height')
		this._subscribe(value)
		this._updateAll()
	}

	onCenterInChanged: {
		var item = this.parent
		var anchors = this
		item._removeUpdater('x')
		item._removeUpdater('y')
		this._subscribe(value)
		this._subscribe(item)
		this._updateAll()
	}

	onLeftMarginChanged,
	onRightMarginChanged,
	onTopMarginChanged,
	onBottomMarginChanged,
	onMarginChanged:		{ this.marginsUpdated(); this._updateAll(); }
}
