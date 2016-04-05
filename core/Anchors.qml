Object {
	property AnchorLine bottom;
	property AnchorLine verticalCenter;
	property AnchorLine top;

	property AnchorLine left;
	property AnchorLine horizontalCenter;
	property AnchorLine right;

	property Item fill;
	property Item centerIn;

	property int margins;
	property int bottomMargin;
	property int topMargin;
	property int leftMargin;
	property int rightMargin;

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

	function _update(name) {
		var self = this.parent
		var anchors = this

		switch(name) {
			case 'left':
				var update_left = this._updateLeft.bind(this)
				update_left()
				anchors.left.parent.on('boxChanged', update_left)
				anchors.onChanged('leftMargin', update_left)
				break

			case 'right':
				var update_right = this._updateRight.bind(this)
				update_right()
				self.onChanged('width', update_right)
				anchors.right.parent.on('boxChanged', update_right)
				anchors.onChanged('rightMargin', update_right)
				break

			case 'top':
				var update_top = this._updateTop.bind(this)
				update_top()
				anchors.top.parent.on('boxChanged', update_top)
				anchors.onChanged('topMargin', update_top)
				break

			case 'bottom':
				var update_bottom = this._updateBottom.bind(this)
				update_bottom()
				self.onChanged('height', update_bottom)
				anchors.bottom.parent.on('boxChanged', update_bottom)
				anchors.onChanged('bottomMargin', update_bottom)
				break

			case 'horizontalCenter':
				var update_h_center = this._updateHCenter.bind(this)
				update_h_center()
				self.onChanged('width', update_h_center)
				anchors.onChanged('leftMargin', update_h_center)
				anchors.onChanged('rightMargin', update_h_center)
				anchors.horizontalCenter.parent.on('boxChanged', update_h_center)
				break

			case 'verticalCenter':
				var update_v_center = this._updateVCenter.bind(this)
				update_v_center()
				self.onChanged('height', update_v_center)
				anchors.onChanged('topMargin', update_v_center)
				anchors.onChanged('bottomMargin', update_v_center)
				anchors.verticalCenter.parent.on('boxChanged', update_v_center)
				break

			case 'fill':
				anchors.left = anchors.fill.left
				anchors.right = anchors.fill.right
				anchors.top = anchors.fill.top
				anchors.bottom = anchors.fill.bottom
				break

			case 'centerIn':
				anchors.horizontalCenter = anchors.centerIn.horizontalCenter
				anchors.verticalCenter = anchors.centerIn.verticalCenter
				break
		}
		qml.core.Object.prototype._update.apply(this, arguments)
	}

}
