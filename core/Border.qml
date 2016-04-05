Object {
	property int width;
	property color color;

	property BorderMargin left :	BorderMargin	{ name: "left"; }
	property BorderMargin right :	BorderMargin	{ name: "right"; }
	property BorderMargin top :		BorderMargin	{ name: "top"; }
	property BorderMargin bottom :	BorderMargin	{ name: "bottom"; }

	function _update(name, value) {
		switch(name) {
			case 'width': this.parent.style({'border-width': value, 'margin-left': -value, 'margin-top': -value}); break;
			case 'color': this.parent.style('border-color', qml.core.normalizeColor(value)); break;
		}
		qml.core.Object.prototype._update.apply(this, arguments)
	}

}
