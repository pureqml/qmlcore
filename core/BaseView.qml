///base class for all views, holds content, creates delegates and provides common api
BaseLayout {
	signal layoutFinished;
	property Object model;			///< model object to attach to
	property Item delegate;			///< delegate - template object, filled with model row
	property int contentX;			///< x offset to visible part of the content surface
	property int contentY;			///< y offset to visible part of the content surface
	property int scrollingStep: 0;	///< scrolling step
	property int animationDuration: 0;
	property string animationEasing: "ease";
	property bool contentFollowsCurrentItem: true;	///< auto-scroll content to current focused item
	property bool nativeScrolling;	///< allows native scrolling on mobile targets and shows native scrollbars
	property real prerender: 0.5;	///< allocate additional delegates by viewport (prerender * horizontal/vertical view size) px
	property enum positionMode		{ Contain, Beginning, Center, End, Visible, Page }; ///< position mode for auto-scrolling/position methods
	property string visibilityProperty; ///< if this property is false, delegate is not created at all
	contentWidth: 1;				///< content width
	contentHeight: 1;				///< content height
	keyNavigationWraps: true;		///< key navigation wraps from end to beginning and vise versa
	handleNavigationKeys: true;		///< handle navigation keys

	/// @internal
	property BaseViewContent content: BaseViewContent {
		cssTranslatePositioning: parent.cssTranslatePositioning;

		Behavior on x, y, transform { Animation { duration: parent.parent.animationDuration; easing: parent.parent.animationEasing; } }
	}

	onContentXChanged: { this.content.x = -value; }
	onContentYChanged: { this.content.y = -value; }

	/// @private
	constructor: {
		this._items = []
		this._modelUpdate = new $core.model.ModelUpdate()
		this._attached = null

		//callback instances for dynamic model subscriptions
		this._modelReset = this._onReset.bind(this)
		this._modelRowsInserted = this._onRowsInserted.bind(this)
		this._modelRowsChanged = this._onRowsChanged.bind(this)
		this._modelRowsRemoved =  this._onRowsRemoved.bind(this)
	}

	/// returns index of item by x,y coordinates
	function itemAt(x, y) {
		var idx = this.indexAt(x, y)
		return idx >= 0? this._items[idx]: null
	}

	/// @private focuses current item
	function focusCurrent() {
		var n = this.count
		if (n === 0)
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

	onModelChanged: {
		if (this.trace)
			log('model changed to ', value)

		this._detach()
		this._modelUpdate.clear()
		this._removeItems(0, this.count)
		this.count = 0
		this._scheduleLayout()
	}

	/// @private
	function _onReset() {
		var model = this._attached
		if (this.trace)
			log("reset", this._items.length, model.count)

		this._modelUpdate.reset(model)
		this._scheduleLayout()
	}

	/// @private
	function _onRowsInserted(begin, end) {
		if (this.trace)
			log("rows inserted", begin, end)

		this._modelUpdate.insert(this._attached, begin, end)
		this._scheduleLayout()
	}

	/// @private
	function _onRowsChanged(begin, end) {
		if (this.trace)
			log("rows changed", begin, end)

		this._modelUpdate.update(this._attached, begin, end)
		this._scheduleLayout()
	}

	/// @private
	function _onRowsRemoved(begin, end) {
		if (this.trace)
			log("rows removed", begin, end)

		this._modelUpdate.remove(this._attached, begin, end)
		this._scheduleLayout()
	}

	/// @private
	function _attach() {
		if (this._attached || !this.model || !this.delegate)
			return

		if (this.trace)
			log('attaching model...')

		var Model = $core.Model
		var model = this.model
		var modelType = typeof model
		if ((Model !== undefined) && (model instanceof Model)) {
		} else if (Array.isArray(model)) {
			model = new $core.model.ArrayModelWrapper(model)
		} else if (modelType === 'number') {
			var data = []
			for(var i = 0; i < model; ++i)
				data.push({})
			model = new $core.model.ArrayModelWrapper(data)
		} else
			throw new Error("unknown value of type '" + (typeof model) + "', attached to model property: " + model + ((modelType === 'object') && ('componentName' in model)? ', component name: ' + model.componentName: ''))

		model.on('reset', this._modelReset)
		model.on('rowsInserted', this._modelRowsInserted)
		model.on('rowsChanged', this._modelRowsChanged)
		model.on('rowsRemoved', this._modelRowsRemoved)

		this._attached = model
		this._onReset()
	}

	/// @private
	function _detach() {
		var model = this._attached
		if (!model)
			return

		if (this.trace)
			log('detaching model...')

		this._attached = null

		model.removeListener('reset', this._modelReset)
		model.removeListener('rowsInserted', this._modelRowsInserted)
		model.removeListener('rowsChanged', this._modelRowsChanged)
		model.removeListener('rowsRemoved', this._modelRowsRemoved)
	}

	onDelegateChanged: {
		if (value)
			value.visible = false
	}

	/// @private creates delegate in given item slot
	function _createDelegate(idx) {
		var items = this._items
		var item = items[idx]
		if (item !== null && item !== undefined)
			return item

		var visibilityProperty = this.visibilityProperty
		var row = this._attached.get(idx)

		if (this.trace)
			log('createDelegate', idx, row)

		if (visibilityProperty && !row[visibilityProperty])
			return null;
		row.index = idx

		item = this.delegate(this, row)
		items[idx] = item
		item.view = this
		item.element.remove()
		this.content.element.append(item.element)

		item.recursiveVisible = this.recursiveVisible && item.visible && item.visibleInView

		return item
	}

	/// @private
	function _updateDelegate(idx) {
		var item = this._items[idx]
		if (item) {
			var row = this._attached.get(idx)
			row.index = idx
			item._local.model = row
			var _row = item._createPropertyStorage('_row')
			_row.callOnChanged(item, '_row')
		}
	}

	/// @private
	function _updateDelegateIndex(idx) {
		var item = this._items[idx]
		if (item) {
			item._local.model.index = idx
			var _rowIndex = item._createPropertyStorage('_rowIndex')
			_rowIndex.callOnChanged(item, '_rowIndex')
		}
	}

	function discard() {
		this._detach()
		$core.BaseLayout.prototype.discard.apply(this)
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
		var args = new Array(n)
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
		this.count = this._items.length
	}

	onRecursiveVisibleChanged: {
		if (value)
			this._scheduleLayout();

		var view = this
		this._items.forEach(function(child) {
			if (child !== null)
				view._updateVisibilityForChild(child, value)
		})
		this._updateVisibilityForChild(this.content, value)
	}

	onWidthChanged:				{ this._scheduleLayout() }
	onHeightChanged:			{ this._scheduleLayout() }

	///@private silently updates scroll positions, because browser animates scroll
	function _updateScrollPositions(x, y, layout) {
		this._setProperty('contentX', x)
		this._setProperty('contentY', y)
		this.content._updateScrollPositions(x, y, layout)
	}

	function positionViewAtItemHorizontally(itemBox, center, centerOversized) {
		var cx = this.contentX, cy = this.contentY
		var x = itemBox[0], y = itemBox[1]
		var iw = itemBox[2], ih = itemBox[3]
		var w = this.width, h = this.height

		var atCenter = x - w / 2 + iw / 2
		if (iw > w)
			this.contentX = centerOversized? atCenter: x
		else if (center && this.contentWidth > w)
			this.contentX = atCenter < 0 ? 0 : x > this.contentWidth - w / 2 - iw / 2 ? this.contentWidth - w : atCenter
		else if (x - cx <= 0)
			this.contentX = x
		else if (x - cx + iw > w)
			this.contentX = x + iw - w
	}

	function positionViewAtItemVertically(itemBox, center, centerOversized) {
		var cx = this.contentX, cy = this.contentY
		var x = itemBox[0], y = itemBox[1]
		var iw = itemBox[2], ih = itemBox[3]
		var w = this.width, h = this.height

		var atCenter = y - h / 2 + ih / 2
		if (ih > h)
			this.contentY = centerOversized? atCenter: y
		else if (center && this.contentHeight > h)
			this.contentY = atCenter < 0 ? 0 : y > this.contentHeight - h / 2 - ih / 2 ? this.contentHeight - h : atCenter
		else if (y - cy <= 0)
			this.contentY = y
		else if (y - cy + ih > h)
			this.contentY = y + ih - h
	}


	onCompleted: {
		var self = this
		this.element.on('scroll', function(event) {
			self._updateScrollPositions(self.element.dom.scrollLeft, self.element.dom.scrollTop)
		}.bind(this))
	}
}
