/// Colored rectangle with optional rounded corners, border and/or gradient.
Item {
	property color color: "#0000";		///< rectangle background color
	property Border border: Border {}	///< object holding properties of the border
	property Gradient gradient;			///< if gradient object was set, it displays gradient instead of solid color

	///@private
	function _mapCSSAttribute(name) {
		var attr = {color: 'background-color'}[name]
		return (attr !== undefined)?
			attr:
			_globals.core.Item.prototype._mapCSSAttribute.apply(this, arguments)
	}

	onColorChanged: { this.style('background-color', _globals.core.normalizeColor(value)) }
}
