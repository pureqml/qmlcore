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
		this._scheduleUpdate = function() { this._context.delayedAction('update-anchors', this, this._updateAll) }.bind(this)
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

		var toScreen = function(line) {
			var object = line[0], index = line[1]
			return object.toScreen()[index]
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
		}

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
		}
	}

	/** @private */
	function _subscribe(src) {
		var items = this._items
		//connect only once per item
		if (items.indexOf(src) < 0) {
			items.push(src)
			this.connectOn(src, 'boxChanged', this._scheduleUpdate)
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
		this._subscribe(value[0])
		this._scheduleUpdate()
	}

	onRightChanged: {
		var item = this.parent
		var anchors = this
		item._removeUpdater('x')
		if (anchors.left || anchors.horizontalCenter) {
			anchors._removeUpdater('width')
		}
		this._subscribe(item)
		this._subscribe(value[0])
		this._scheduleUpdate()
	}

	onHorizontalCenterChanged: {
		var item = this.parent
		var anchors = this
		item._removeUpdater('x')
		if (anchors.left || anchors.right) {
			anchors._removeUpdater('width')
		}
		this._subscribe(item)
		this._subscribe(value[0])
		this._scheduleUpdate()

	}
	onTopChanged: {
		var item = this.parent
		var anchors = this
		item._removeUpdater('y')
		if (anchors.bottom || anchors.verticalCenter) {
			item._removeUpdater('height')
			this._subscribe(item)
		}
		this._subscribe(value[0])
		this._scheduleUpdate()

	}
	onBottomChanged: {
		var item = this.parent
		var anchors = this
		item._removeUpdater('y')
		if (anchors.top || anchors.verticalCenter) {
			item._removeUpdater('height')
		}
		this._subscribe(item)
		this._subscribe(value[0])
		this._scheduleUpdate()
	}

	onVerticalCenterChanged: {
		var item = this.parent
		var anchors = this
		item._removeUpdater('y')
		if (anchors.top || anchors.bottom) {
			item._removeUpdater('height')
		}
		this._subscribe(item)
		this._subscribe(value[0])
		this._scheduleUpdate()
	}

	onFillChanged: {
		var item = this.parent
		var anchors = this
		item._removeUpdater('x')
		item._removeUpdater('width')
		item._removeUpdater('y')
		item._removeUpdater('height')
		this._subscribe(value)
		this._scheduleUpdate()
	}

	onCenterInChanged: {
		var item = this.parent
		var anchors = this
		item._removeUpdater('x')
		item._removeUpdater('y')
		this._subscribe(value)
		this._subscribe(item)
		this._scheduleUpdate()
	}

	onLeftMarginChanged,
	onRightMarginChanged,
	onTopMarginChanged,
	onBottomMarginChanged,
	onMarginChanged:		{ this.marginsUpdated(); this._scheduleUpdate(); }
}
