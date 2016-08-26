Object {
	property real blur;
	property real grayscale;
	property real sepia;
	property real brightness;
	property real contrast;
	property real hueRotate;
	property real invert;
	property real saturate;
	property Shadow shadow : Shadow { }

	function _addStyle(array, property, style, units) {
		var value = this[property]
		if (value)
			array.push((style || property) + '(' + value + (units || '') + ') ')
	}

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

	function _updateStyle() {
		var filterStyle = this._getFilterStyle().join('')
		var parent = this.parent

		var style = {}
		var updateStyle = false

		if (filterStyle.length > 0) {
			//chromium bug
			//https://github.com/Modernizr/Modernizr/issues/981
			style['-webkit-filter'] = filterStyle
			style['filter'] = filterStyle
			updateStyle = true
		}

		if (this.shadow && !this.shadow._empty()) {
			style['box-shadow'] = this.shadow._getFilterStyle()
			updateStyle = true
		}

		if (updateStyle) {
			//log(style)
			parent.style(style)
		}
	}

	function _update(name, value) {
		this._updateStyle()
		qml.core.Object.prototype._update.apply(this, arguments)
	}

}
