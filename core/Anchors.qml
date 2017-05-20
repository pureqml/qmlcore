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
		var self = anchors.parent
		var parent = self.parent

		var parent_box = parent.toScreen()
		var left = anchors.left.toScreen()

		var lm = anchors.leftMargin || anchors.margins
		self.x = left + lm - parent_box[0] - self.viewX
		if (anchors.right) {
			var right = anchors.right.toScreen()
			var rm = anchors.rightMargin || anchors.margins
			self.width = right - left - rm - lm
		}
	}

	/** @private */
	function _updateRight() {
		var anchors = this
		var self = anchors.parent
		var parent = self.parent

		var parent_box = parent.toScreen()
		var right = anchors.right.toScreen()

		var lm = anchors.leftMargin || anchors.margins
		var rm = anchors.rightMargin || anchors.margins
		if (anchors.left) {
			var left = anchors.left.toScreen()
			self.width = right - left - rm - lm
		}
		self.x = right - parent_box[0] - rm - self.width - self.viewX
	}

	/** @private */
	function _updateTop() {
		var anchors = this
		var self = anchors.parent
		var parent = self.parent

		var parent_box = parent.toScreen()
		var top = anchors.top.toScreen()

		var tm = anchors.topMargin || anchors.margins
		var bm = anchors.bottomMargin || anchors.margins
		self.y = top + tm - parent_box[1] - self.viewY
		if (anchors.bottom) {
			var bottom = anchors.bottom.toScreen()
			self.height = bottom - top - bm - tm
		}
	}

	/** @private */
	function _updateBottom() {
		var anchors = this
		var self = anchors.parent
		var parent = self.parent

		var parent_box = parent.toScreen()
		var bottom = anchors.bottom.toScreen()

		var tm = anchors.topMargin || anchors.margins
		var bm = anchors.bottomMargin || anchors.margins
		if (anchors.top) {
			var top = anchors.top.toScreen()
			self.height = bottom - top - bm - tm
		}
		self.y = bottom - parent_box[1] - bm - self.height - self.viewY
	}

	/** @private */
	function _updateHCenter() {
		var anchors = this
		var self = anchors.parent
		var parent = self.parent

		var parent_box = parent.toScreen();
		var hcenter = anchors.horizontalCenter.toScreen();
		var lm = anchors.leftMargin || anchors.margins;
		var rm = anchors.rightMargin || anchors.margins;
		self.x = hcenter - self.width / 2 - parent_box[0] + lm - rm - self.viewX;
	}

	/** @private */
	function _updateVCenter() {
		var anchors = this
		var self = anchors.parent
		var parent = self.parent

		var parent_box = parent.toScreen();
		var vcenter = anchors.verticalCenter.toScreen();
		var tm = anchors.topMargin || anchors.margins;
		var bm = anchors.bottomMargin || anchors.margins;
		self.y = vcenter - self.height / 2 - parent_box[1] + tm - bm - self.viewY;
	}

	onLeftChanged: {
		var self = this.parent
		var anchors = this
		self._removeUpdater('x')
		if (anchors.right)
			self._removeUpdater('width')
		var update_left = anchors._updateLeft.bind(this)
		update_left()
		self.connectOn(anchors.left.parent, 'boxChanged', update_left)
		anchors.onChanged('leftMargin', update_left)
	}

	onRightChanged: {
		var self = this.parent
		var anchors = this
		self._removeUpdater('x')
		if (anchors.left)
			anchors._removeUpdater('width')
		var update_right = anchors._updateRight.bind(anchors)
		update_right()
		self.onChanged('width', update_right)
		self.connectOn(anchors.right.parent, 'boxChanged', update_right)
		anchors.onChanged('rightMargin', update_right)
	}

	onTopChanged: {
		var self = this.parent
		var anchors = this
		self._removeUpdater('y')
		if (anchors.bottom)
			self._removeUpdater('height')
		var update_top = anchors._updateTop.bind(this)
		update_top()
		self.connectOn(anchors.top.parent, 'boxChanged', update_top)
		anchors.onChanged('topMargin', update_top)
	}

	onBottomChanged: {
		var self = this.parent
		var anchors = this
		self._removeUpdater('y')
		if (anchors.top)
			self._removeUpdater('height')
		var update_bottom = anchors._updateBottom.bind(this)
		update_bottom()
		self.onChanged('height', update_bottom)
		self.connectOn(anchors.bottom.parent, 'boxChanged', update_bottom)
		anchors.onChanged('bottomMargin', update_bottom)
	}

	onHorizontalCenterChanged: {
		var self = this.parent
		var anchors = this
		self._removeUpdater('x')
		var update_h_center = anchors._updateHCenter.bind(this)
		update_h_center()
		self.onChanged('width', update_h_center)
		anchors.onChanged('leftMargin', update_h_center)
		anchors.onChanged('rightMargin', update_h_center)
		self.connectOn(anchors.horizontalCenter.parent, 'boxChanged', update_h_center)
	}

	onVerticalCenterChanged: {
		var self = this.parent
		var anchors = this
		var update_v_center = anchors._updateVCenter.bind(this)
		self._removeUpdater('y')
		update_v_center()
		self.onChanged('height', update_v_center)
		anchors.onChanged('topMargin', update_v_center)
		anchors.onChanged('bottomMargin', update_v_center)
		self.connectOn(anchors.verticalCenter.parent, 'boxChanged', update_v_center)
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
