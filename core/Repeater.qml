///The simplest view implementation, creates elements without positioning
BaseView {

	function _layout() {
		if (!this.recursiveVisible)
			return

		var model = this.model;
		if (!model)
			return

		var n = this.count = model.count
		var items = this._items
		for(var i = 0; i < n; ++i) {
			var item = items[i]
			if (!item)
				item = this._createDelegate(i)
		}
	}

}
