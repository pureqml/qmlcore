/// class controlling object transformation
Object {
	property int perspective;	///< perspective transformation
	property int translateX;	///< x-translate
	property int translateY;	///< y-translate
	property int translateZ;	///< z-translate
	property real rotateX;		///< x-axis rotation
	property real rotateY;		///< y-axis rotation
	property real rotateZ;		///< z-axis rotation
	property real rotate;		///< rotate relative transform point
	property real scaleX;		///< horizontal scale
	property real scaleY;		///< vertical scale
	property real skewX;		///< horizontal skew
	property real skewY;		///< vertical skew

	///@private
	constructor: { this._transforms = {} }

	onPerspectiveChanged:	{ this._transforms['perspective'] = value + 'px'; this._updateTransform() }
	onTranslateXChanged:	{ this._transforms['translateX'] = value + 'px'; this._updateTransform() }
	onTranslateYChanged:	{ this._transforms['translateY'] = value + 'px'; this._updateTransform() }
	onTranslateZChanged:	{ this._transforms['translateZ'] = value + 'px'; this._updateTransform() }
	onRotateXChanged:		{ this._transforms['rotateX'] = value + 'deg'; this._updateTransform() }
	onRotateYChanged:		{ this._transforms['rotateY'] = value + 'deg'; this._updateTransform() }
	onRotateZChanged:		{ this._transforms['rotateZ'] = value + 'deg'; this._updateTransform() }
	onRotateChanged:		{ this._transforms['rotate'] = value + 'deg'; this._updateTransform() }
	onScaleXChanged:		{ this._transforms['scaleX'] = value; this._updateTransform() }
	onScaleYChanged:		{ this._transforms['scaleY'] = value; this._updateTransform() }
	onSkewXChanged:			{ this._transforms['skewX'] = value + 'deg'; this._updateTransform() }
	onSkewYChanged:			{ this._transforms['skewY'] = value + 'deg'; this._updateTransform() }

	function _updateTransform() {
		var str = ""
		for (var i in this._transforms) {
			str += i
			str += "(" + this._transforms[i] + ") "
		}
		this.parent.style('transform', str)
	}
}
