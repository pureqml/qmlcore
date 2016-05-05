Item {
	property string value;
	property string accept;
	width: 250;
	height: 20;

	function _update(name, value) {
		switch (name) {
			case 'width': this._updateSize(); break
			case 'height': this._updateSize(); break
		}

		qml.core.Item.prototype._update.apply(this, arguments);
	}

	constructor: {
		this.element.remove()
		this.element = $(document.createElement('input'))
		this.element[0].setAttribute("type", "file");
		var self = this
		this.element[0].onchange = function(e) { self.value = e.target.value }
		this.parent.element.append(this.element)
	}

	function _updateSize() {
		var style = { width: this.width, height: this.height }
		this.style(style)
	}
}
