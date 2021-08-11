BaseMixin {
	property string cursor;			///< mouse cursor

	///@private
	constructor: {
		this._touchEvent = false
		if (this.cursor)
			this.parent.style('cursor', this.cursor)
	}

	function _setTouchEvent() {
		this._touchEvent = true
	}

	function _resetTouchEvent() {
		this._touchEvent = false
	}

	/// @private pops touch event flag to skip mouse over later
	function _trueUnlessTouchEvent() {
		return !this._touchEvent
	}

	onCursorChanged: {
		this.parent.style('cursor', value)
	}
}
