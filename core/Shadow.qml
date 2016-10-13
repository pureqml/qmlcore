Object {
	property real x;
	property real y;
	property Color color: "black";
	property real blur;
	property real spread;

	function _update(name, value) {
		this.parent._updateStyle()
		_globals.core.Object.prototype._update.apply(this, arguments);
	}

	function _empty() {
		return !this.x && !this.y && !this.blur && !this.spread;
	}

	function _getFilterStyle() {
		var style = this.x + "px " + this.y + "px " + this.blur + "px "
		if (this.spread > 0)
			style += this.spread + "px "
		style += new _globals.core.Color(this.color).get()
		return style
	}

}
