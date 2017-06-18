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

	///@private
	constructor: {
		this.count = 0
		this._delayedLayout = new _globals.core.DelayedAction(this._context, function() {
			this._processUpdates()
			this._layout()
		}.bind(this))
	}

	///@private
	function _processUpdates() { }

	onSpacingChanged: { this._delayedLayout.schedule(); }
}
