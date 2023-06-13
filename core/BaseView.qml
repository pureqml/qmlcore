///base class for all views, holds content, creates delegates and provides common api
BaseLayout {
	signal layoutFinished;
	signal scrollEvent;
	signal modelUpdated;
	property Item highlight;		///< an object that follows currentIndex and placed below other elements
	property Object model;			///< model object to attach to
	property Item delegate;			///< delegate - template object, filled with model row
	property int contentX;			///< x offset to visible part of the content surface
	property int contentY;			///< y offset to visible part of the content surface
	property int scrollingStep: 0;	///< scrolling step
	property int animationDuration: 0;
	property string animationEasing: "ease";
	property bool contentFollowsCurrentItem: !nativeScrolling;	///< auto-scroll content to current focused item
	property bool nativeScrolling: context.system.device === context.system.Mobile; ///< allows native scrolling on mobile targets and shows native scrollbars
	property real prerender: 0.5;	///< allocate additional delegates by viewport (prerender * horizontal/vertical view size) px
	property enum positionMode		{ Contain, Center, Visible, Page, End }; ///< position mode for auto-scrolling/position methods
	property string visibilityProperty; ///< if this property is false, delegate is not created at all
	contentWidth: 1;				///< content width
	contentHeight: 1;				///< content height
	keyNavigationWraps: true;		///< key navigation wraps from end to beginning and vise versa
	handleNavigationKeys: true;		///< handle navigation keys

	cssPointerTouchEvents: nativeScrolling; // enable touch/pointer events for natively scrollable surfaces

	/// @internal
	property BaseViewContent content: BaseViewContent {
		cssTranslatePositioning: parent.cssTranslatePositioning;
		cssPointerTouchEvents: parent.cssPointerTouchEvents;

		Behavior on x, y, transform {
			Animation {
				duration: parent.parent.nativeScrolling? 0: parent.parent.animationDuration;
				easing: parent.parent.animationEasing;
			}
		}
	}

	property ContentMargin contentMargin: ContentMargin { }

	onContentXChanged: {
		if (this.nativeScrolling)
			this.element.setScrollX(value)
		else
			this.content.x = -value
	}
	onContentYChanged: {
		if (this.nativeScrolling)
			this.element.setScrollY(value)
		else
			this.content.y = -value
	}

	/// @private
	constructor: {
		this._items = []
		this._modelUpdate = new $core.model.ModelUpdate()
		this.__moveDir = 0
	}

	/// returns index of item by x,y coordinates
	function itemAt(x, y) {
		var idx = this.indexAt(x, y)
		return idx >= 0? this._items[idx]: null
	}

	/// @private updates highlight
	function _updateHighlight(item) {
		var highlight = this.highlight
		if (!highlight || !item)
			return

		highlight.viewX = item.viewX
		highlight.viewY = item.viewY
		highlight.width = item.width
		highlight.height = item.height
		//see explanations in onHighlightChanged
		highlight.newBoundingBox()
	}

	function _updateHighlightForCurrentItem() {
		this._updateHighlight(this.itemAtIndex(this.currentIndex))
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
		var item = this.itemAtIndex(idx)

		if (item)
			this.focusChild(item)
		if (this.contentFollowsCurrentItem && !this._skipPositioning)
			this.positionViewAtIndex(idx)

		this._updateHighlight(item)
	}

	onFocusedChildChanged: {
		var idx = this._items.indexOf(this.focusedChild)
		if (idx >= 0)
			this.currentIndex = idx
	}

	function moveCurrentIndex(dir) {
		var ci = this.currentIndex
		var wrap = this.keyNavigationWraps
		var count = this.count
		var outOfRange = false
		this.__moveDir = dir
		ci += dir
		if (wrap) {
			ci %= count
			if (ci < 0)
				ci += count
		} else {
			if (ci < 0) {
				ci = 0
				outOfRange = true
			}
			if (ci >= count) {
				ci = count - 1
				outOfRange = true
			}
		}
		if (outOfRange || ci < 0 || ci >= count)
			return false

		this.currentIndex = ci
		return true
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
		var model = this._modelAttached
		if (this.trace)
			log("reset", this._items.length, model.count)

		this._modelUpdate.reset(model)
		this._scheduleLayout()
	}

	/// @private
	function _onRowsInserted(begin, end) {
		if (this.trace)
			log("rows inserted", begin, end)

		this._modelUpdate.insert(this._modelAttached, begin, end)
		this._scheduleLayout()
	}

	/// @private
	function _onRowsChanged(begin, end) {
		if (this.trace)
			log("rows changed", begin, end)

		this._modelUpdate.update(this._modelAttached, begin, end)
		this._scheduleLayout()
	}

	/// @private
	function _onRowsRemoved(begin, end) {
		if (this.trace)
			log("rows removed", begin, end)

		this._modelUpdate.remove(this._modelAttached, begin, end)
		this._scheduleLayout()
	}

	/// @private
	function _attach() {
		if (this._modelAttached || !this.model || !this.delegate)
			return

		if (this.trace)
			log('attaching model...')

		this.model.attachTo(this)
	}

	/// @private
	function _detach() {
		var model = this._modelAttached
		if (!model)
			return

		if (this.trace)
			log('detaching model...')

		model.detachFrom(this)
	}

	onDelegateChanged: {
		if (value)
			value.visible = false
	}

	/// @private creates delegate in given item slot
	function _createDelegate(idx, callback) {
		var items = this._items
		var item = items[idx]
		if (item !== null && item !== undefined)
			return item

		var visibilityProperty = this.visibilityProperty
		var row = this._modelAttached.get(idx)

		if (visibilityProperty && !row[visibilityProperty])
			return null;

		if (this.trace)
			log('createDelegate', idx, row)

		row.index = idx

		item = this.delegate(this, row)
		items[idx] = item
		item.view = this
		item.element.remove()

		if (callback === undefined)
			this.content.element.append(item.element)
		else
			callback.call(this, item)

		item.recursiveVisible = this.recursiveVisible && item.visible && item.visibleInView

		return item
	}

	/// @private
	function _updateDelegate(idx) {
		var item = this._items[idx]
		if (item) {
			var row = this._modelAttached.get(idx)
			row.index = idx
			item._local.model = row
			var _row = item._createPropertyStorage('_row')
			_row.callOnChanged(item, '_row', row, {})
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
		var updated = this._modelUpdate.apply(this)
		qml.core.BaseLayout.prototype._processUpdates.apply(this)
		this.count = this._items.length

		if (updated)
			this.modelUpdated()
	}

	onRecursiveVisibleChanged: {
		if (value)
			this._scheduleLayout();
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
		var cx = this.contentX
		var x = itemBox[0]
		var iw = itemBox[2]
		var w = this.width
		var cmr = this.contentMargin.right
		var cml = this.contentMargin.left

		var atCenter = x - w / 2 + iw / 2
		if (iw > w)
			this.contentX = centerOversized? atCenter: x
		else if (center && this.contentWidth > w)
			this.contentX = atCenter < -cml ? -cml : x > this.contentWidth - w / 2 - iw / 2 + cmr ? this.contentWidth - w + cmr : atCenter
		else if (x <= cml)
			this.contentX = -cml
		else if (x - cx <= 0)
			this.contentX = x
		else if (x - cx + iw > w)
			this.contentX = x + iw - w + cmr
	}

	function positionViewAtItemVertically(itemBox, center, centerOversized) {
		var cy = this.contentY
		var y = itemBox[1]
		var ih = itemBox[3]
		var h = this.height
		var cmt = this.contentMargin.top
		var cmb = this.contentMargin.bottom

		var atCenter = y - h / 2 + ih / 2
		if (ih > h)
			this.contentY = centerOversized? atCenter: y
		else if (center && this.contentHeight > h)
			this.contentY = atCenter < -cmt ? -cmt : y > this.contentHeight - h / 2 - ih / 2 + cmb ? this.contentHeight - h + cmb : atCenter
		else if (y <= cmt)
			this.contentY = -cmt
		else if (y - cy <= 0)
			this.contentY = y
		else if (y - cy + ih + cmb > h)
			this.contentY = y + ih - h + cmb
	}

	function positionViewAtEndHorizontally() {
		var w = this.width
		var cmr = this.contentMargin.right
		var cml = this.contentMargin.left

		var end = this.contentWidth + cmr
		var pos = end - w
		if (pos > -cml)
			this.contentX = pos
	}

	function positionViewAtEndVertically() {
		var h = this.height
		var cmb = this.contentMargin.bottom
		var cmt = this.contentMargin.top

		var end = this.contentHeight + cmb
		var pos = end - h
		if (pos > -cmt)
			this.contentY = pos
	}

	function itemAtIndex(idx) {
		var item = this._items[idx]
		return item? item: null
	}

	onLayoutFinished: {
		this.focusCurrent()
		this._updateHighlightForCurrentItem()
	}

	onHighlightChanged: {
		var highlight = value
		if (highlight) {
			/*
			* FIXME: highlight is a child of BaseView in QML hierarchy, at the same time
			* it's a child of content in element hierarchy.
			* This results in toScreen() return coordinates relative to BaseView. It renders
			* impossible to follow natively scrollable surfaces with something like VideoPlayer
			*/
			highlight.view = this //this makes toScreen adjust position according to scroll position

			highlight.element.remove()
			this.content.element.prepend(highlight.element)
		}
	}

	onCompleted: {
		var self = this
		this.element.on('scroll', function() {
			var x = self.element.getScrollX(), y = self.element.getScrollY()
			self._updateScrollPositions(x, y)
			self.scrollEvent(x, y)
		}.bind(this))
	}
}
