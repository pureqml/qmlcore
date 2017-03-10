/// provides shadow properties adjustment
Object {
	property real x;	///< x coordinate
	property real y;	///< y coordinate
	property Color color: "black";	///< color of the shadow
	property real blur;				///< applies a blur effect on the shadow
	property real spread;			///< adjusts a spread distance of the shadow

	/// @private
	function _update(name, value) {
		this.parent._updateStyle(true)
		_globals.core.Object.prototype._update.apply(this, arguments);
	}

	/// @private
	function _empty() {
		return !this.x && !this.y && !this.blur && !this.spread;
	}

	/// @private
	function _getFilterStyle() {
		var style = this.x + "px " + this.y + "px " + this.blur + "px "
		if (this.spread > 0)
			style += this.spread + "px "
		style += _globals.core.normalizeColor(this.color)
		return style
	}
}
