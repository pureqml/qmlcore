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

		var left, top, right, bottom
		if (leftAnchor) {
			left = leftAnchor.toScreen()
			item.x = left + lm - parent_box[0] - item.viewX
		}

		if (rightAnchor) {
			right = rightAnchor.toScreen()
			item.x = right - parent_box[0] - rm - item.width - item.viewX
		}

		if (leftAnchor && rightAnchor) {
			item.width = right - left - rm - lm
		}

		if (topAnchor) {
			top = topAnchor.toScreen()
			item.y = top + tm - parent_box[1] - item.viewY
		}

		if (bottomAnchor) {
			bottom = bottomAnchor.toScreen()
			item.y = bottom - parent_box[1] - bm - item.height - item.viewY
		}

		if (topAnchor && bottomAnchor) {
			item.height = bottom - top - bm - tm
		}

		if (hcenterAnchor) {
			var hcenter = hcenterAnchor.toScreen();
			item.x = hcenter - item.width / 2 - parent_box[0] + lm - rm - item.viewX;
		}

		if (vcenterAnchor) {
			var vcenter = vcenterAnchor.toScreen();
			item.y = vcenter - item.height / 2 - parent_box[1] + tm - bm - item.viewY;
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
		this._updateAll()
	}

	onLeftChanged: {
		var item = this.parent
		var anchors = this
		item._replaceUpdater('x')
		if (anchors.right)
			item._replaceUpdater('width')
		this._subscribe(value.parent)
	}

	onRightChanged: {
		var item = this.parent
		var anchors = this
		item._replaceUpdater('x')
		if (anchors.left)
			anchors._replaceUpdater('width')
		this._subscribe(value.parent)
	}

	onTopChanged: {
		var item = this.parent
		var anchors = this
		item._replaceUpdater('y')
		if (anchors.bottom)
			item._replaceUpdater('height')
		this._subscribe(value.parent)
	}

	onBottomChanged: {
		var item = this.parent
		var anchors = this
		item._replaceUpdater('y')
		if (anchors.top)
			item._replaceUpdater('height')
		this._subscribe(value.parent)
	}

	onHorizontalCenterChanged: {
		var item = this.parent
		var anchors = this
		item._replaceUpdater('x')
		this._subscribe(value.parent)
	}

	onVerticalCenterChanged: {
		var item = this.parent
		var anchors = this
		item._replaceUpdater('y')
		this._subscribe(value.parent)
	}

	onFillChanged: {
		var item = this.parent
		var anchors = this
		item._replaceUpdater('x')
		item._replaceUpdater('width')
		item._replaceUpdater('y')
		item._replaceUpdater('height')
		this._subscribe(value)
	}

	onCenterInChanged: {
		var item = this.parent
		var anchors = this
		item._replaceUpdater('x')
		item._replaceUpdater('y')
		this._subscribe(value)
	}

	onLeftMarginChanged,
	onRightMarginChanged,
	onTopMarginChanged,
	onBottomMarginChanged,
	onMarginChanged:		{ this.marginsUpdated(); this._updateAll(); }
}
