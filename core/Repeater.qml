///The simplest view implementation, creates elements without positioning
BaseView {

	///@private
	function positionViewAtIndex() { }

	///@private
	function _layout() {
		if (!this.recursiveVisible && !this.offlineLayout) {
			this.layoutFinished()
			return
		}

		var model = this._modelAttached;
		if (!model) {
			this.layoutFinished()
			return
		}

		var created = false;
		var n = this.count = model.count
		var items = this._items
		for(var i = 0; i < n; ++i) {
			var item = items[i]
			if (!item) {
				item = this._createDelegate(i)
				created = true
			}
		}
		this.layoutFinished()
	}

	/// @private creates delegate in given item slot
	function _createDelegate(idx) {
		var delegate = $core.BaseView.prototype._createDelegate.call(this, idx, function(delegate) {
			var parent = this.parent
			parent.element.append(delegate.element)
			parent.addChild(delegate)
		}.bind(this))
		return delegate
	}

	function _discardItem(item) {
		this.parent.removeChild(item)
		$core.BaseView.prototype._discardItem.apply(this, arguments)
	}

	onLayoutFinished: {
		//request layout from parent if it's layout
		var parent = this.parent
		if (parent && parent._scheduleLayout) {
			parent._scheduleLayout()
		}
	}
}
