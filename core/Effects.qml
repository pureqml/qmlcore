///provides various visual effects
Object {
	property real blur;			///< applies a blur effect to the image
	property real grayscale;	///< converts the image to grayscale
	property real sepia;		///< converts the image to sepia
	property real brightness;	///< adjusts the brightness of the image
	property real contrast;		///< adjusts the contrast of the image
	property real hueRotate;	///< applies a hue rotation on the image. The value defines the number of degrees around the color circle the image samples will be adjusted
	property real invert;		///< inverts the samples in the image
	property real saturate;		///< saturates the image
	property lazy shadow : Shadow { }	///< object property for the shadow adjusting

	/// @private
	function _addStyle(array, property, style, units) {
		var value = this[property]
		if (value)
			array.push((style || property) + '(' + value + (units || '') + ') ')
	}

	/// @private
	function _getFilterStyle() {
		var style = []
		this._addStyle(style, 'blur', 'blur', 'px')
		this._addStyle(style, 'grayscale')
		this._addStyle(style, 'sepia')
		this._addStyle(style, 'brightness')
		this._addStyle(style, 'contrast')
		this._addStyle(style, 'hueRotate', 'hue-rotate', 'deg')
		this._addStyle(style, 'invert')
		this._addStyle(style, 'saturate')
		return style
	}

	/// @private
	function _updateStyle(updateShadow) {
		var filterStyle = this._getFilterStyle().join('')
		var parent = this.parent
		var style = {}

		//chromium bug
		//https://github.com/Modernizr/Modernizr/issues/981
		style['-webkit-filter'] = filterStyle
		style['filter'] = filterStyle

		if (this.shadow && (!this.shadow._empty() || updateShadow))
			style['box-shadow'] = this.shadow._getFilterStyle()

		parent.style(style)
	}

	onBlurChanged, onGrayscaleChanged,
	onSepiaChanged, onBrightnessChanged,
	onContrastChanged, onHueRotateChanged,
	onInvertChanged, onSaturateChanged: { this._updateStyle() }
}
