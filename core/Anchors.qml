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

	/** @private */
	function _updateLeft() {
		var anchors = this
		var item = anchors.parent
		var parent = item.parent

		var parent_box = parent.toScreen()
		var left = anchors.left.toScreen()

		var lm = anchors.leftMargin || anchors.margins
		item.x = left + lm - parent_box[0] - item.viewX
		if (anchors.right) {
			var right = anchors.right.toScreen()
			var rm = anchors.rightMargin || anchors.margins
			item.width = right - left - rm - lm
		}
	}

	/** @private */
	function _updateRight() {
		var anchors = this
		var item = anchors.parent
		var parent = item.parent

		var parent_box = parent.toScreen()
		var right = anchors.right.toScreen()

		var lm = anchors.leftMargin || anchors.margins
		var rm = anchors.rightMargin || anchors.margins
		if (anchors.left) {
			var left = anchors.left.toScreen()
			item.width = right - left - rm - lm
		}
		item.x = right - parent_box[0] - rm - item.width - item.viewX
	}

	/** @private */
	function _updateTop() {
		var anchors = this
		var item = anchors.parent
		var parent = item.parent

		var parent_box = parent.toScreen()
		var top = anchors.top.toScreen()

		var tm = anchors.topMargin || anchors.margins
		var bm = anchors.bottomMargin || anchors.margins
		item.y = top + tm - parent_box[1] - item.viewY
		if (anchors.bottom) {
			var bottom = anchors.bottom.toScreen()
			item.height = bottom - top - bm - tm
		}
	}

	/** @private */
	function _updateBottom() {
		var anchors = this
		var item = anchors.parent
		var parent = item.parent

		var parent_box = parent.toScreen()
		var bottom = anchors.bottom.toScreen()

		var tm = anchors.topMargin || anchors.margins
		var bm = anchors.bottomMargin || anchors.margins
		if (anchors.top) {
			var top = anchors.top.toScreen()
			item.height = bottom - top - bm - tm
		}
		item.y = bottom - parent_box[1] - bm - item.height - item.viewY
	}

	/** @private */
	function _updateHCenter() {
		var anchors = this
		var item = anchors.parent
		var parent = item.parent

		var parent_box = parent.toScreen();
		var hcenter = anchors.horizontalCenter.toScreen();
		var lm = anchors.leftMargin || anchors.margins;
		var rm = anchors.rightMargin || anchors.margins;
		item.x = hcenter - item.width / 2 - parent_box[0] + lm - rm - item.viewX;
	}

	/** @private */
	function _updateVCenter() {
		var anchors = this
		var item = anchors.parent
		var parent = item.parent

		var parent_box = parent.toScreen();
		var vcenter = anchors.verticalCenter.toScreen();
		var tm = anchors.topMargin || anchors.margins;
		var bm = anchors.bottomMargin || anchors.margins;
		item.y = vcenter - item.height / 2 - parent_box[1] + tm - bm - item.viewY;
	}

	onLeftChanged: {
		var item = this.parent
		var anchors = this
		item._replaceUpdater('x')
		if (anchors.right)
			item._replaceUpdater('width')
		var update_left = anchors._updateLeft.bind(this)
		update_left()
		item.connectOn(anchors.left.parent, 'boxChanged', update_left)
		anchors.onChanged('leftMargin', update_left)
	}

	onRightChanged: {
		var item = this.parent
		var anchors = this
		item._replaceUpdater('x')
		if (anchors.left)
			anchors._replaceUpdater('width')
		var update_right = anchors._updateRight.bind(anchors)
		update_right()
		item.onChanged('width', update_right)
		item.connectOn(anchors.right.parent, 'boxChanged', update_right)
		anchors.onChanged('rightMargin', update_right)
	}

	onTopChanged: {
		var item = this.parent
		var anchors = this
		item._replaceUpdater('y')
		if (anchors.bottom)
			item._replaceUpdater('height')
		var update_top = anchors._updateTop.bind(this)
		update_top()
		item.connectOn(anchors.top.parent, 'boxChanged', update_top)
		anchors.onChanged('topMargin', update_top)
	}

	onBottomChanged: {
		var item = this.parent
		var anchors = this
		item._replaceUpdater('y')
		if (anchors.top)
			item._replaceUpdater('height')
		var update_bottom = anchors._updateBottom.bind(this)
		update_bottom()
		item.onChanged('height', update_bottom)
		item.connectOn(anchors.bottom.parent, 'boxChanged', update_bottom)
		anchors.onChanged('bottomMargin', update_bottom)
	}

	onHorizontalCenterChanged: {
		var item = this.parent
		var anchors = this
		item._replaceUpdater('x')
		var update_h_center = anchors._updateHCenter.bind(this)
		update_h_center()
		item.onChanged('width', update_h_center)
		anchors.onChanged('leftMargin', update_h_center)
		anchors.onChanged('rightMargin', update_h_center)
		item.connectOn(anchors.horizontalCenter.parent, 'boxChanged', update_h_center)
	}

	onVerticalCenterChanged: {
		var item = this.parent
		var anchors = this
		var update_v_center = anchors._updateVCenter.bind(this)
		item._replaceUpdater('y')
		update_v_center()
		item.onChanged('height', update_v_center)
		anchors.onChanged('topMargin', update_v_center)
		anchors.onChanged('bottomMargin', update_v_center)
		item.connectOn(anchors.verticalCenter.parent, 'boxChanged', update_v_center)
	}

	onFillChanged: {
		var fill = value
		this.left = fill.left
		this.right = fill.right
		this.top = fill.top
		this.bottom = fill.bottom
	}

	onCenterInChanged: {
		this.horizontalCenter = value.horizontalCenter
		this.verticalCenter = value.verticalCenter
	}

	onLeftMarginChanged,
	onRightMarginChanged,
	onTopMarginChanged,
	onBottomMarginChanged,
	onMarginChanged:		{ this.marginsUpdated(); }
}
