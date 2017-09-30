/// adjusts text font properties
Object {
	property string family: manifest.style.font.family;		///< font family
	property bool italic;		///< applies italic style
	property bool bold;			///< applies bold style
	property bool underline;	///< applies underline style
	property bool strike;		///< line throw text flag
	property real letterSpacing;	///< spacing between letters
	property int pixelSize: manifest.style.font.pixelSize;		///< font size in pixels
	property int pointSize;		///< font size in points
	property int lineHeight;	///< font line height in pixels
	property int weight;		///< font weight value

	onFamilyChanged:		{ this.parent.style('font-family', value); this.parent._updateSize() }
	onPointSizeChanged:		{ if (value > 0) this.pixelSize = 0; this.parent.style('font-size', value > 0? value + 'pt': ''); this.parent._updateSize() }
	onPixelSizeChanged:		{ if (value > 0) this.pointSize = 0; this.parent.style('font-size', value > 0? value + 'px': ''); this.parent._updateSize() }
	onItalicChanged: 		{ this.parent.style('font-style', value? 'italic': 'normal'); this.parent._updateSize() }
	onBoldChanged: 			{ this.parent.style('font-weight', value? 'bold': 'normal'); this.parent._updateSize() }
	onUnderlineChanged:		{ this.parent.style('text-decoration', value? 'underline': ''); this.parent._updateSize() }
	onStrikeChanged:		{ this.parent.style('text-decoration', value? 'line-through': ''); this.parent._updateSize() }
	onLineHeightChanged:	{ this.parent.style('line-height', value + "px"); this.parent._updateSize() }
	onWeightChanged:		{ this.parent.style('font-weight', value); this.parent._updateSize() }
	onLetterSpacingChanged:	{ this.parent.style('letter-spacing', value + "px"); this.parent._updateSize() }
}
