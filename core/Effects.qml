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

	function _addStyle(property, style, units) {
		var value = this[property]
		if (!value)
			return ''
		return (style || property) + '(' + value + (units || '') + ') '
	}

	function _getFilterStyle() {
		var style = []
		style.push(this._addStyle('blur', 'blur', 'px'))
		style.push(this._addStyle('grayscale'))
		style.push(this._addStyle('sepia'))
		style.push(this._addStyle('brightness'))
		style.push(this._addStyle('contrast'))
		style.push(this._addStyle('hueRotate', 'hue-rotate', 'deg'))
		style.push(this._addStyle('invert'))
		style.push(this._addStyle('saturate'))
		return style.join('')
	}

	function _updateStyle() {
		var filterStyle = this._getFilterStyle()
		var parent = this.parent
		//chromium bug
		//https://github.com/Modernizr/Modernizr/issues/981
		var style = {'-webkit-filter': filterStyle, 'filter': filterStyle }
		if (this.shadow && !this.shadow._empty())
			style['box-shadow'] = this.shadow._getFilterStyle()
		parent.style(style)
	}

	function _update(name, value) {
		this._updateStyle()
		qml.core.Object.prototype._update.apply(this, arguments)
	}

}
