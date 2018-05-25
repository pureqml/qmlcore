/**
@private
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
					pp.style(cssname, this.width + "px solid " + _globals.core.Color.normalize(this.color))
				} else
					pp.style(cssname, '')
			}
		}
	}

	onWidthChanged,
	onColorChanged: { this._updateStyle() }
}
