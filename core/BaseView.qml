Item {
	property Object model;
	property Item delegate;

	property int count;
	property int currentIndex;
	property int contentX;
	property int contentY;
	property int contentWidth: 1;
	property int contentHeight: 1;
	property int scrollingStep: 0;

	property bool handleNavigationKeys: true;
	property bool keyNavigationWraps: true;
	property bool contentFollowsCurrentItem: true;
	property bool pageScrolling: false;
	property bool rendered: false;

	property enum positionMode { Beginning, Center, End, Visible, Contain, Page };

	property bool trace;

	constructor: {
		this._items = []
		var self = this
		this._delayedLayout = new qml.core.DelayedAction(function() {
			self._layout()
		})
	}

	function itemAt(x, y) {
		var idx = this.indexAt(x, y)
		return idx >= 0? this._items[idx]: null
	}

	function positionViewAtIndex(idx) {
		var cx = this.contentX, cy = this.contentY
		var itemBox = this.getItemPosition(idx)
		var x = itemBox[0], y = itemBox[1]
		var iw = itemBox[2], ih = itemBox[3]
		var w = this.width, h = this.height
		var horizontal = this.orientation == this.Horizontal
		var center = this.positionMode === this.Center

		if (horizontal) {
			var atCenter = x - w / 2 + iw / 2
			if (center && this.contentWidth > w)
				this.contentX = atCenter < 0 ? 0 : x > this.contentWidth - w / 2 - iw / 2 ? this.contentWidth - w : atCenter
			else if (iw > w)
				this.contentX = atCenter
			else if (x - cx < 0)
				this.contentX = x
			else if (x - cx + iw > w)
				this.contentX = x + iw - w
		} else {
			var atCenter = y - h / 2 + ih / 2
			if (center && this.contentHeight > h)
				this.contentY = atCenter < 0 ? 0 : y > this.contentHeight - h / 2 - ih / 2 ? this.contentHeight - h : atCenter
			else if (ih > h)
				this.contentY = atCenter
			else if (y - cy < 0)
				this.contentY = y
			else if (y - cy + ih > h)
				this.contentY = y + ih - h
		}
	}

	function focusCurrent() {
		var n = this.count
		if (n == 0)
			return

		var idx = this.currentIndex
		if (idx < 0 || idx >= n) {
			if (this.keyNavigationWraps)
				this.currentIndex = (idx + n) % n
			else
				this.currentIndex = idx < 0? 0: n - 1
			return
		}
		var item = this._items[idx]

		if (item)
			this.focusChild(item)
		if (this.contentFollowsCurrentItem)
			this.positionViewAtIndex(idx)
	}

	onFocusedChildChanged: {
		var idx = this._items.indexOf(this.focusedChild)
		if (idx >= 0)
			this.currentIndex = idx
	}

	onCurrentIndexChanged: {
		this.focusCurrent()
	}

	function _onReset() {
		var model = this.model
		var items = this._items
		if (this.trace)
			log("reset", items.length, model.count)

		if (items.length == model.count && items.length == 0)
			return

		if (items.length > model.count) {
			if (model.count != items.length)
				this._onRowsRemoved(model.count, items.length)
			if (items.length > 0)
				this._onRowsChanged(0, items.length)
		} else {
			if (items.length > 0)
				this._onRowsChanged(0, items.length)
			if (model.count != items.length)
				this._onRowsInserted(items.length, model.count)
		}
		if (items.length != model.count)
			throw "reset failed"
		this._delayedLayout.schedule()
	}

	function _onRowsInserted(begin, end) {
		if (this.trace)
			log("rows inserted", begin, end)
		var items = this._items
		for(var i = begin; i < end; ++i)
			items.splice(i, 0, null)
		if (items.length != this.model.count)
			throw "insert failed"
		this._delayedLayout.schedule()
	}

	function _onRowsChanged(begin, end) {
		if (this.trace)
			log("rows changed", begin, end)
		var items = this._items
		for(var i = begin; i < end; ++i) {
			var item = items[i];
			if (item && item.element)
				item.element.remove()
			items[i] = null
		}
		if (items.length != this.model.count)
			throw "change failed"
		this._delayedLayout.schedule()
	}

	function _onRowsRemoved(begin, end) {
		log("rows removed", begin, end)
		var items = this._items
		for(var i = begin; i < end; ++i) {
			var item = items[i];
			if (item && item.element)
				item.element.remove()
			items[i] = null
		}
		items.splice(begin, end - begin)
		if (items.length != this.model.count)
			throw "remove failed"
		this._delayedLayout.schedule()
	}

	function _attach() {
		if (this._attached || !this.model || !this.delegate)
			return

		this.model.on('reset', this._onReset.bind(this))
		this.model.on('rowsInserted', this._onRowsInserted.bind(this))
		this.model.on('rowsChanged', this._onRowsChanged.bind(this))
		this.model.on('rowsRemoved', this._onRowsRemoved.bind(this))
		this._attached = true
		this._onReset()
	}

	function _update(name, value) {
		switch(name) {
		case 'delegate':
			if (value)
				value.visible = false
			break
		}
		qml.core.Item.prototype._update.apply(this, arguments);
	}

	function _createDelegate(idx) {
		var row = this.model.get(idx)
		this._local['model'] = row
		var item = this.delegate()
		this._items[idx] = item
		item.view = this
		item.element.remove()
		this.content.element.append(item.element)
		item._local['model'] = row
		delete this._local['model']
		return item
	}

	content: BaseViewContent { }

	onContentXChanged: { this.content.x = -value; }
	onContentYChanged: { this.content.y = -value; }

	onRecursiveVisibleChanged:	{ if (value) this._delayedLayout.schedule(); }
	onWidthChanged:				{ this._delayedLayout.schedule() }
	onHeightChanged:			{ this._delayedLayout.schedule() }
	onCompleted:				{
		this._attach();
		var delayedLayout = this._delayedLayout
		this.element.scroll(function(event) { this.contentX = this.element.scrollLeft(); this.contentY = this.element.scrollTop() }.bind(this))
		delayedLayout.schedule()
	}

//	Behavior on contentX { Animation { duration: 300; } }
//	Behavior on contentY { Animation { duration: 300; } }
}
