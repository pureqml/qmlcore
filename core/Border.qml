/// class controlling border rendering
Object {
	property int width;		///< width of the border
	property color color;	///< color of the border
	property string style;	///< style of the border

	property lazy left:		BorderSide	{ name: "left"; }		///< left border side
	property lazy right:	BorderSide	{ name: "right"; }		///< right border side
	property lazy top:		BorderSide	{ name: "top"; }		///< top border side
	property lazy bottom:	BorderSide	{ name: "bottom"; }		///< bottom border side

	///@private
	onWidthChanged: { this.parent.style({'border-width': value, 'margin-left': -value, 'margin-top': -value}) }
	onColorChanged: { this.parent.style('border-color', _globals.core.Color.normalize(value)) }
	onStyleChanged: { this.parent.style('border-style', value) }
}
