/// class controlling border rendering
Object {
	property int width;		///< width of the border
	property color color: "black";	///< color of the border
	property enum style { None, Hidden, Dotted, Dashed, Solid, Double, Groove, Ridge, Inset, Outset }: Solid; ///< style of the border

	property lazy left:		BorderSide	{ name: "left"; }		///< left border side
	property lazy right:	BorderSide	{ name: "right"; }		///< right border side
	property lazy top:		BorderSide	{ name: "top"; }		///< top border side
	property lazy bottom:	BorderSide	{ name: "bottom"; }		///< bottom border side

	///@private
	onWidthChanged: { this.parent.style({'border-width': value}) }
	onColorChanged: {
		var newColor = _globals.core.Color.normalize(this.color)
		this.parent.style('border-color', newColor)
	}
	onStyleChanged: {
		var styleName
		switch(this.style) {
		case this.None: styleName = 'none'; break
		case this.Hidden: styleName = 'hidden'; break
		case this.Dotted: styleName = 'dotted'; break
		case this.Dashed: styleName = 'dashed'; break
		case this.Solid: styleName = 'solid'; break
		case this.Double: styleName = 'double'; break
		case this.Groove: styleName = 'groove'; break
		case this.Ridge: styleName = 'ridge'; break
		case this.Inset: styleName = 'inset'; break
		case this.Outset: styleName = 'outset'; break
		}

		this.parent.style('border-style', styleName)
	}
}
