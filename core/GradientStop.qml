/// this object is used for customizing Gradient
Object {
	property real position;	///< realative position ot the stop must be in range [0:1]
	property Color color;	///< color of this stop

	///@private
	onPositionChanged, onColorChanged: {
		this.parent._updateStyle()
	}

	///@private
	function _getDeclaration() {
		return _globals.core.Color.normalize(this.color) + " " + Math.floor(100 * this.position) + "%"
	}
}
