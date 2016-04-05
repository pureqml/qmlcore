Item {
	property color color: "#000";

	property Border border: Border {}
	property Gradient gradient;

	function _mapCSSAttribute(name) {
		var attr = {color: 'background-color'}[name]
		return (attr !== undefined)?
			attr:
			exports.core.Item.prototype._mapCSSAttribute.apply(this, arguments)
	}

	function _update(name, value) {
		switch(name) {
			case 'color': this.style('background-color', exports.core.normalizeColor(value)); break;
			case 'gradient': {
				if (value) {
					var decl = value._getDeclaration()
					this.style({ 'background-color': '', 'background': window.Modernizr.prefixedCSSValue('background', 'linear-gradient(to ' + decl + ')') })
				} else {
					this.style('background', '')
					this._update('color', exports.core.normalizeColor(this.color)) //restore color
				}
				break;
			}
		}
		exports.core.Item.prototype._update.apply(this, arguments);
	}

}
