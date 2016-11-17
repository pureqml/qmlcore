/**
@internal
Component aimed to adjust individual preferences of each border side
*/

Object {
	property string name;
	property int width;
	property color color;

	function _updateStyle() {
		if (this.parent && this.parent.parent) {
			var pp = this.parent.parent
			if (pp) {
				var cssname = 'border-' + this.name
				if (this.width) {
					pp.style(cssname, this.width + "px solid " + _globals.core.normalizeColor(this.color))
				} else
					pp.style(cssname, '')
			}
		}
	}

	function _update(name, value) {
		switch(name) {
			case 'width': this._updateStyle(); break
			case 'color': this._updateStyle(); break
		}
		_globals.core.Object.prototype._update.apply(this, arguments);
	}
}
