///base class for all views, holds content, creates delegates and provides common api
BaseLayout {
	signal layoutFinished;
	property Object model;			///< model object to attach to
	property Item delegate;			///< delegate - template object, filled with model row
	property int contentX;			///< x offset to visible part of the content surface
	property int contentY;			///< y offset to visible part of the content surface
	property int scrollingStep: 0;	///< scrolling step
	property int animationDuration: 0;
	property bool contentFollowsCurrentItem: true;	///< auto-scroll content to current focused item
	property real prerender: 0.5;	///< allocate additional delegates by viewport (prerender * horizontal/vertical view size) px
	property enum positionMode { Beginning, Center, End, Visible, Contain, Page }; ///< position mode for auto-scrolling/position methods
	contentWidth: 1;				///< content width
	contentHeight: 1;				///< content height
	keyNavigationWraps: true;		///< key navigation wraps from end to beginning and vise versa
	handleNavigationKeys: true;		///< handle navigation keys

	/// returns index of item by x,y coordinates
	function itemAt(x, y) {
		var idx = this.indexAt(x, y)
		return idx >= 0? this._items[idx]: null
	}

	/// @private focuses current item
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

	/// @private
	constructor: {
		this._items = []
		this._modelUpdate = new _globals.core.model.ModelUpdate()
	}

	/// @private
	onFocusedChildChanged: {
		var idx = this._items.indexOf(this.focusedChild)
		if (idx >= 0)
			this.currentIndex = idx
	}

	/// @private
	onCurrentIndexChanged: {
		this.focusCurrent()
	}

	/// @private
	function _onReset() {
		var model = this.model
		if (this.trace)
			log("reset", this._items.length, model.count)

		this._modelUpdate.reset(model)
		this._delayedLayout.schedule()
	}

	/// @private
	function _onRowsInserted(begin, end) {
		if (this.trace)
			log("rows inserted", begin, end)

		this._modelUpdate.insert(this.model, begin, end)
		this._delayedLayout.schedule()
	}

	/// @private
	function _onRowsChanged(begin, end) {
		if (this.trace)
			log("rows changed", begin, end)

		this._modelUpdate.update(this.model, begin, end)
		this._delayedLayout.schedule()
	}

	/// @private
	function _onRowsRemoved(begin, end) {
		if (this.trace)
			log("rows removed", begin, end)

		this._modelUpdate.remove(this.model, begin, end)
		this._delayedLayout.schedule()
	}

	/// @private
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

	onDelegateChanged: {
		if (value)
			value.visible = false
	}

	/// @private creates delegate in given item slot
	function _createDelegate(idx) {
		var items = this._items
		if (items[idx] !== null)
			return

		var row = this.model.get(idx)
		row['index'] = idx
		this._local['model'] = row

		var item = this.delegate(this)
		items[idx] = item
		item.view = this
		item.element.remove()
		this.content.element.append(item.element)

		item._local['model'] = row
		delete this._local['model']
		item.recursiveVisible = this.recursiveVisible && item.visible && item.visibleInView

		return item
	}

	/// @private
	function _updateDelegate(idx) {
		var item = this._items[idx]
		if (item) {
			var row = this.model.get(idx)
			row.index = idx
			item._local.model = row
			_globals.core.Object.prototype._update.call(item, '_row')
		}
	}

	/// @private
	function _updateDelegateIndex(idx) {
		var item = this._items[idx]
		if (item) {
			item._local.model.index = idx
			_globals.core.Object.prototype._update.call(item, '_rowIndex')
		}
	}

	/// @private
	function _discardItem(item) {
		if (item === null)
			return
		if (this.focusedChild === item)
			this.focusedChild = null;
		item.discard()
	}

	/// @private
	function _insertItems(begin, end) {
		var n = end - begin + 2
		var args = Array(n)
		args[0] = begin
		args[1] = 0
		for(var i = 2; i < n; ++i)
			args[i] = null
		Array.prototype.splice.apply(this._items, args)
	}

	/// @private
	function _removeItems(begin, end) {
		var deleted = this._items.splice(begin, end - begin)
		var view = this
		deleted.forEach(function(item) { view._discardItem(item)})
	}

	/// @private
	function _updateItems(begin, end) {
		for(var i = begin; i < end; ++i)
			this._updateDelegate(i)
	}

	/// @private
	function _processUpdates() {
		this._modelUpdate.apply(this)
		qml.core.BaseLayout.prototype._processUpdates.apply(this)
	}

	/// @internal
	property BaseViewContent content: BaseViewContent {
		Behavior on x, y, transform { Animation { duration: parent.parent.animationDuration; } }
	}

	onContentXChanged: { this.content.x = -value; }
	onContentYChanged: { this.content.y = -value; }

	onRecursiveVisibleChanged: {
		if (value)
			this._delayedLayout.schedule();

		this._items.forEach(function(child) {
			if (child !== null)
				child.recursiveVisible = value && child.visible && child.visibleInView
		})
	}

	onWidthChanged:				{ this._delayedLayout.schedule() }
	onHeightChanged:			{ this._delayedLayout.schedule() }

	///@private silently updates scroll positions, because browser animates scroll
	function _updateScrollPositions(x, y) {
		this._setProperty('contentX', x)
		this._setProperty('contentY', y)
		this.content._updateScrollPositions(x, y)
	}

	onCompleted:				{
		this._attach();
		var delayedLayout = this._delayedLayout

		var self = this
		this.element.on('scroll', function(event) {
			self._updateScrollPositions(self.element.dom.scrollLeft, self.element.dom.scrollTop)
		}.bind(this))

		delayedLayout.schedule()
	}
}
