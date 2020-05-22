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
	constructor: { this._transforms = new $core.transform.Transform() }

	onPerspectiveChanged:	{ this._transforms.add('perspective', value, 'px'); this._updateTransform() }
	onTranslateXChanged:	{ this._transforms.add('translateX', value, 'px'); this._updateTransform() }
	onTranslateYChanged:	{ this._transforms.add('translateY', value, 'px'); this._updateTransform() }
	onTranslateZChanged:	{ this._transforms.add('translateZ', value, 'px'); this._updateTransform() }
	onRotateXChanged:		{ this._transforms.add('rotateX', value, 'deg'); this._updateTransform() }
	onRotateYChanged:		{ this._transforms.add('rotateY', value, 'deg'); this._updateTransform() }
	onRotateZChanged:		{ this._transforms.add('rotateZ', value, 'deg'); this._updateTransform() }
	onRotateChanged:		{ this._transforms.add('rotate', value, 'deg'); this._updateTransform() }
	onScaleXChanged:		{ this._transforms.add('scaleX', value); this._updateTransform() }
	onScaleYChanged:		{ this._transforms.add('scaleY', value); this._updateTransform() }
	onSkewXChanged:			{ this._transforms.add('skewX', value, 'deg'); this._updateTransform() }
	onSkewYChanged:			{ this._transforms.add('skewY', value, 'deg'); this._updateTransform() }

	function _updateTransform() {
		this.parent.style('transform', this._transforms)
	}
}
