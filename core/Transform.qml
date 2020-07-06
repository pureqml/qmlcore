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

	///@private instead of animating transform property in Item, animate each property in Transform object
	///unfortunately animations are not const, though it's a good idea to make them so (and save on animation instances)
	///this function is meant to be called from non-html backends to animate transformations.
	///see backend.js in platform/pure.femto for details
	function _animateAll(animation) {
		var transform = this
		var transform_properties = [
			'perspective',
			'translateX', 'translateY', 'translateZ',
			'rotateX', 'rotateY', 'rotateZ', 'rotate',
			'scaleX', 'scaleY',
			'skewX', 'skewY'
		]
		transform_properties.forEach(function(transform_property) {
			var property_animation = new $core.Animation(transform)
			$core.core.createObject(property_animation)
			property_animation.delay = animation.delay
			property_animation.duration = animation.duration
			property_animation.easing = animation.easing

			transform.setAnimation(transform_property, property_animation)
		})
	}

	///@private
	function getAnimation(name) {
		var animation = $core.Object.prototype.getAnimation.call(this, name)
		if (!animation) {
			animation = $core.Object.prototype.getAnimation.call(this.parent, 'transform')
		}
		return animation
	}
}
