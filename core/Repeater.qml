///The simplest view implementation, creates elements without positioning
BaseView {

	function _layout() {
		if (!this.recursiveVisible)
			return

		var model = this.model;
		if (!model)
			return

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
		this.rendered = true
		if (created)
			this._context._complete()
	}

}
