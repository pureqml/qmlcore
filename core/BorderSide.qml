/**
@private
Component aimed to adjust individual preferences of each border side
*/

Object {
	// property enum type { Inner, Outer, Center }; ///< whether box is inside bounding rect or not
	property string name;
	property int width: parent.width;
	property color color: parent.color;
	property int style: parent.style;
	property int type: parent.type;

	///@private
	function _updateStyle() {
		if (!this.parent || !this.parent.parent || !this.name)
			return

		var Border = $core.Border
		var styleName
		switch(this.style) {
		case Border.None: styleName = 'none'; break
		case Border.Hidden: styleName = 'hidden'; break
		case Border.Dotted: styleName = 'dotted'; break
		case Border.Dashed: styleName = 'dashed'; break
		case Border.Solid: styleName = 'solid'; break
		case Border.Double: styleName = 'double'; break
		case Border.Groove: styleName = 'groove'; break
		case Border.Ridge: styleName = 'ridge'; break
		case Border.Inset: styleName = 'inset'; break
		case Border.Outset: styleName = 'outset'; break
		}

		var borderCss = this.width + "px " + styleName + " " + $core.Color.normalize(this.color)
		this.parent.parent.style('border-' + this.name, borderCss)
	}

	///@private
	onWidthChanged,
	onColorChanged,
	onStyleChanged: { this._updateStyle() }
}
