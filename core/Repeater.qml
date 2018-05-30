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

		var model = this._attached;
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
		if (created)
			this._context.scheduleComplete()
	}
}
