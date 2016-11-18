///base class for all views, holds content, creates delegates and provides common api
BaseLayout {
	property Object model;			///< model object to attach to
	property Item delegate;			///< delegate - template object, filled with model row
	property int contentX;			///< x offset to visible part of the content surface
	property int contentY;			///< y offset to visible part of the content surface
	property int scrollingStep: 0;	///< scrolling step
	property bool contentFollowsCurrentItem: true;	///< auto-scroll content to current focused item
	property bool pageScrolling: false;
	property bool rendered: false;
	property bool trace;
	property enum positionMode { Beginning, Center, End, Visible, Contain, Page }; ///< position mode for auto-scrolling/position methods
	contentWidth: 1;				///< content width
	contentHeight: 1;				///< content height
	keyNavigationWraps: true;		///< key navigation wraps from end to beginning and vise versa
	handleNavigationKeys: true;		///< handle navigation keys

	constructor: {
		this._items = []
		this._modelEvents = []
	}

	/// returns index of item by x,y coordinates
	function itemAt(x, y) {
		var idx = this.indexAt(x, y)
		return idx >= 0? this._items[idx]: null
	}

	/// @internal focuses current item
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

	/** @private */
	function _onReset() {
		var model = this.model
		var items = this._items
		if (this.trace)
			log("reset", items.length, model.count)

		var ModelEvent = _globals.core.ModelEvent
		this._modelEvents.push(new ModelEvent(model, ModelEvent.Reset))
		this._delayedLayout.schedule()
	}

	/** @private */
	function _onRowsInserted(begin, end) {
		if (this.trace)
			log("rows inserted", begin, end)

		var ModelEvent = _globals.core.ModelEvent
		for(var i = begin; i < end; ++i)
			this._modelEvents.push(new ModelEvent(model, ModelEvent.Insert, begin, end))
		this._delayedLayout.schedule()
	}

	/** @private */
	function _onRowsChanged(begin, end) {
		if (this.trace)
			log("rows changed", begin, end)

		var ModelEvent = _globals.core.ModelEvent
		for(var i = begin; i < end; ++i)
			this._modelEvents.push(new ModelEvent(model, ModelEvent.Change, begin, end))
		this._delayedLayout.schedule()
	}

	/** @private */
	function _onRowsRemoved(begin, end) {
		if (this.trace)
			log("rows removed", begin, end)

		var ModelEvent = _globals.core.ModelEvent
		for(var i = begin; i < end; ++i)
			this._modelEvents.push(new ModelEvent(model, ModelEvent.Remove, begin, end))
		this._delayedLayout.schedule()
	}

	/** @private */
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

	/** @private */
	function _update(name, value) {
		switch(name) {
		case 'delegate':
			if (value)
				value.visible = false
			break
		}
		_globals.core.Item.prototype._update.apply(this, arguments);
	}

	/// @internal creates delegate in given item slot
	function _createDelegate(idx) {
		var items = this._items
		if (items[idx] !== null)
			return

		var row = this.model.get(idx)
		row['index'] = idx
		this._local['model'] = row

		var item = this.delegate()
		items[idx] = item
		item.view = this
		item.element.remove()
		this.content.element.append(item.element)

		item._local['model'] = row
		delete this._local['model']
		return item
	}

	function _updateDelegate(idx) {
		var item = this._items[idx]
		if (item) {
			_globals.core.Object.prototype._update.apply(item, ['_row']);
		}
	}

	function _discardItem(item) {
		if (item === null)
			return
		if (this.focusedChild === item)
			this.focusedChild = null;
		item.discard()
	}

	/// @internal creates delegate in given item slot
	function _discardDelegate(idx) {
		var item = this._items[idx]
		if (item) {
			this._discardItem(item)
			this._items[idx] = null
		}
	}

	function _updateItems() {
		log('update items', this._modelEvents.length)
		qml.core.BaseLayout.prototype._updateItems.apply(this)
	}

	property BaseViewContent content: BaseViewContent { }

	onContentXChanged: { this.content.x = -value; }
	onContentYChanged: { this.content.y = -value; }

	onRecursiveVisibleChanged:	{ if (value) this._delayedLayout.schedule(); }
	onWidthChanged:				{ this._delayedLayout.schedule() }
	onHeightChanged:			{ this._delayedLayout.schedule() }
	onCompleted:				{
		this._attach();
		var delayedLayout = this._delayedLayout

		var self = this
		this.element.on('scroll', function(event) {
			self.contentX = self.element.dom.scrollLeft
			self.contentY = self.element.dom.scrollTop
		}.bind(this))

		delayedLayout.schedule()
	}

//	Behavior on contentX { Animation { duration: 300; } }
//	Behavior on contentY { Animation { duration: 300; } }
}
