/// adjusts text font properties
Object {
	property string family: manifest.style.font.family;		///< font family
	property bool italic;		///< applies italic style
	property bool bold;			///< applies bold style
	property bool underline;	///< applies underline style
	property bool overline;	///< applies overline style
	property bool strike;		///< line throw text flag
	property bool strikeout;		///< line throw text flag for compatibility with QML
	property real letterSpacing;	///< spacing between letters
	property real wordSpacing;	///< spacing between words
	property int pixelSize: manifest.style.font.pixelSize;		///< font size in pixels
	property int pointSize;		///< font size in points
	property real lineHeight: manifest.style.font.lineHeight;	///< font line height in font heights
	property int weight;		///< font weight value
	property enum capitalization { MixedCase, AllUppercase, AllLowercase, SmallCaps, Capitalize };

	signal updated; ///< font style was updated and we need to relayout

	/// get style dictionary - normally you can just pass it to this.element.style(font.getStyle)
	function getStyle() {
		var style = {
			'text-decoration': (this.underline ? ' underline' : '')
				+ (this.overline ? ' overline' : '')
				+ (this.strike || this.strikeout ? ' line-through' : ''),
			'font-family': this.family,
			'font-style': this.italic? 'italic': 'normal',
			'font-weight': this.bold? 'bold': (this.weight > 0? this.weight: 'normal'),
			'line-height': this.lineHeight > 0? this.lineHeight: '',
			'letter-spacing': this.letterSpacing > 0? this.letterSpacing + 'px': '',
			'word-spacing': this.wordSpacing > 0? this.wordSpacing + 'px': '',
			'text-transform': 'none',
			'font-variant': 'normal'
		}
		switch(this.capitalization) {
		case this.AllUppercase: style['text-transform']	= 'uppercase'; break
		case this.AllLowercase: style['text-transform']	= 'lowercase'; break
		case this.SmallCaps: 	style['font-variant']	= 'small-caps'; break
		case this.Capitalize: 	style['text-transform']	= 'capitalize'; break
		}

		if (this.pixelSize > 0)
			style['font-size'] = this.pixelSize + 'px'
		else if (this.pointSize > 0)
			style['font-size'] = this.pointSize + 'pt'
		else
			style['font-size'] = ''

		return style
	}

	/// @private schedule update
	function _update() {
		this._context.delayedAction('font:update', this, this.updated)
	}

	onPointSizeChanged:		{ if (value > 0) this.pixelSize = 0; this._update() }
	onPixelSizeChanged:		{ if (value > 0) this.pointSize = 0; this._update() }

	onFamilyChanged,
	onItalicChanged,
	onBoldChanged,
	onUnderlineChanged,
	onOverlineChanged,
	onStrikeChanged,
	onStrikeoutChanged,
	onLineHeightChanged,
	onWeightChanged,
	onLetterSpacingChanged,
	onWordSpacingChanged,
	onCapitalizationChanged: {
		this._update()
	}
}
