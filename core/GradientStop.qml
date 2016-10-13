Object {
	property real position;
	property Color color;

	function _update() {
		this.parent._update()
	}

	function _getDeclaration() {
		return _globals.core.normalizeColor(this.color) + " " + Math.floor(100 * this.position) + "%"
	}
}
