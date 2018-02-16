/// base class for BaseView and Layout
Item {
	property int count; 					///< number of children elements
	property bool trace;					///< output debug info in logs: layouts, item positioning

	property int spacing;					///< spacing between adjanced items, pixels
	property int currentIndex;				///< index of current focused item
	property int contentWidth;				///< content width
	property int contentHeight;				///< content height
	property bool keyNavigationWraps;		///< key navigation wraps from first to last and vise versa
	property bool handleNavigationKeys;		///< handle navigation keys, move focus
	property int layoutDelay: -1;			///< <0 - end of the tick (default), 0 - request animation frame, >0 - delay in ms
	property int prerenderDelay: -1;		///< <0 - end of the tick (default), 0 - request animation frame, >0 - delay in ms

	///@private
	constructor: {
		this.count = 0
	}

	///@private
	function _scheduleLayout() {
		if (this.prerenderDelay >= 0) {
			this._context.delayedAction('layout', this, this._doLayoutNP, this.layoutDelay)
			this._context.delayedAction('prerender', this, this._doLayout, this.prerenderDelay)
		} else
			this._context.delayedAction('layout', this, this._doLayout, this.layoutDelay)
	}

	///@private
	function _doLayout() {
		this._processUpdates()
		this._layout()
	}

	///@private
	function _doLayoutNP() {
		this._processUpdates()
		this._layout(true)
	}

	///@private
	function _processUpdates() { }

	onSpacingChanged,
	onRecursiveVisibleChanged: {
		if (this.recursiveVisible)
			this._scheduleLayout()
	}
}
