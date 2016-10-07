Item {
	property color color: "#0000";		///< rectangle background color

	property real radius;				///< round corner radius
	property Border border: Border {}	///< object holding properties of the border
	property Gradient gradient;			///< if gradient object was set, it displays gradient instead of solid color

	function _mapCSSAttribute(name) {
		var attr = {color: 'background-color'}[name]
		return (attr !== undefined)?
			attr:
			qml.core.Item.prototype._mapCSSAttribute.apply(this, arguments)
	}

	function _update(name, value) {
		switch(name) {
			case 'color': this.style('background-color', qml.core.normalizeColor(value)); break;
			case 'gradient': {
				if (value) {
					var decl = value._getDeclaration()
					this.style({ 'background-color': '', 'background': 'linear-gradient(to ' + decl + ')' })
				} else {
					this.style('background', '')
					this._update('color', qml.core.normalizeColor(this.color)) //restore color
				}
				break;
			}
		}
		qml.core.Item.prototype._update.apply(this, arguments);
	}

}
