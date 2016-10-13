/// base class for BaseView and Layout
Item {
	property int count; 					///< number of children elements
	property int spacing;					///< spacing between adjanced items, pixels
	property int currentIndex;				///< index of current focused item
	property int contentWidth;				///< content width
	property int contentHeight;				///< content height
	property bool keyNavigationWraps;		///< key navigation wraps from first to last and vise versa
	property bool handleNavigationKeys;		///< handle navigation keys, move focus

	constructor: {
		this.count = 0
		var self = this
		this._delayedLayout = new qml.core.DelayedAction(this._context, function() {
			self._layout()
		})
	}

	function _update(name, value) {
		switch(name) {
			case 'spacing': this._delayedLayout.schedule(); break;
		}
		qml.core.Item.prototype._update.apply(this, arguments);
	}
}
