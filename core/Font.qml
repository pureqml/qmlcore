/// adjusts text font properties
Object {
	property string family;		///< font family
	property bool italic;		///< applies italic style
	property bool bold;			///< applies bold style
	property bool underline;	///< applies underline style
	property bool strike;		///< line throw text flag
	property int pixelSize;		///< font size in pixels
	property int pointSize;		///< font size in points
	property int lineHeight;	///< font line height in pixels
	property int weight;		///< font weight value

	onFamilyChanged:		{ this.parent.style('font-family', value); this.parent._updateSize() }
	onPointSizeChanged:		{ this.parent.style('font-size', value + "pt"); this.parent._updateSize() }
	onPixelSizeChanged:		{ this.parent.style('font-size', value + "px"); this.parent._updateSize() }
	onItalicChanged: 		{ this.parent.style('font-style', value? 'italic': 'normal'); this.parent._updateSize() }
	onBoldChanged: 			{ this.parent.style('font-weight', value? 'bold': 'normal'); this.parent._updateSize() }
	onUnderlineChanged:		{ this.parent.style('text-decoration', value? 'underline': ''); this.parent._updateSize() }
	onStrikeChanged:		{ this.parent.style('text-decoration', value? 'line-through': ''); this.parent._updateSize() }
	onLineHeightChanged:	{ this.parent.style('line-height', value + "px"); this.parent._updateSize() }
	onWeightChanged:		{ this.parent.style('font-weight', value); this.parent._updateSize() }
}
