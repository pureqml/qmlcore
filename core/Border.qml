/// class controlling border rendering
Object {
	property int width;		///< width of the border
	property color color;	///< color of the border
	property string style;	///< style of the border

	property BorderSide left:	BorderSide	{ name: "left"; }		///< left border side
	property BorderSide right:	BorderSide	{ name: "right"; }		///< right border side
	property BorderSide top:	BorderSide	{ name: "top"; }		///< top border side
	property BorderSide bottom:	BorderSide	{ name: "bottom"; }		///< bottom border side

	///@private
	function _update(name, value) {
		switch(name) {
			case 'width': this.parent.style({'border-width': value, 'margin-left': -value, 'margin-top': -value}); break;
			case 'color': this.parent.style('border-color', _globals.core.normalizeColor(value)); break;
			case 'style': this.parent.style('border-style', value); break
		}
		_globals.core.Object.prototype._update.apply(this, arguments)
	}
}
