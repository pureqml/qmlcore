Item {
	property enum horizontalAlignment { AlignLeft, AlignRight, AlignHCenter, Justify };
	height: 20;
	width: 173;
	property string text;
	property int borderWidth: border.width;
	property bool passwordMode: false;
	property Color color: "#000000";
	property Color backgroundColor: "#fff";
	property Font font: Font {}
	property Border border: Border {}

	function _update(name, value) {
		switch (name) {
			case 'text': if (value != this.element[0].value) this.element[0].value = value; break
			case 'width': this._updateSize(); break
			case 'height': this._updateSize(); break
			case 'color': this.style('color', value); break
			case 'backgroundColor': this.style('background', value); break
			case 'passwordMode': this.element[0].setAttribute('type', value ? 'password' : 'text'); break
			case 'borderWidth': this.style('borderStyle', value ? 'inherit' : 'hidden'); break
			case 'horizontalAlignment':
				switch(value) {
				case this.AlignLeft:	this.style('text-align', 'left'); break
				case this.AlignRight:	this.style('text-align', 'right'); break
				case this.AlignHCenter:	this.style('text-align', 'center'); break
				case this.AlignJustify:	this.style('text-align', 'justify'); break
				}
				break
		}

		qml.core.Item.prototype._update.apply(this, arguments);
	}

	constructor: {
		this.element.remove()
		this.element = $(document.createElement('input'))
		var self = this
		this.element[0].oninput = function() { self.text = this.value }
		this.parent.element.append(this.element)
		this.style('borderStyle', 'hidden')
	}

	function _updateSize() {
		var style = { width: this.width, height: this.height }
		this.style(style)
	}
}
