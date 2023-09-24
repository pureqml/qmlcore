/// item with text
Item {
	property string text;		///< text to be displayed
	property color color;		///< color of the text
	property lazy shadow: Shadow { }	///< text shadow object
	property lazy font: Font { }	///< text font object
	property enum horizontalAlignment { AlignLeft, AlignRight, AlignHCenter, AlignJustify };	///< text horizontal alignment
	property enum verticalAlignment { AlignTop, AlignBottom, AlignVCenter };	///< text vertical alignment
	property enum wrapMode { NoWrap, WordWrap, WrapAnywhere, Wrap };	///< multiline text wrap mode
	property enum textFormat { Html, Text }; ///< only html or text for now
	property int paintedWidth;		///< real width of the text without any layout applied
	property int paintedHeight;		///< real height of this text without any layout applied
	width: paintedWidth;
	height: paintedHeight;
	property bool offlineLayout;

	///@private
	constructor: {
		this._context.backend.initText(this)
		if (this.text.length > 0)
			this._setText(this.text)
	}

	htmlClass: "core-text";

	function registerStyle(style, tag) {
		style.addRule(tag, 'width: auto; height: auto;')
	}

	///@private
	function _scheduleUpdateSize() {
		this._context.delayedAction('text:update-size', this, this._updateSizeImpl)
	}

	///@private
	function _setText(html) {
		this._context.backend.setText(this, html)
	}

	///@private
	function onChanged (name, callback) {
		if (!this._updateSizeNeeded) {
			switch(name) {
				case "right":
				case "width":
				case "bottom":
				case "height":
				case "verticalCenter":
				case "horizontalCenter":
					this._enableSizeUpdate()
			}
		}
		$core.Item.prototype.onChanged.apply(this, arguments);
	}

	///@private
	function on(name, callback) {
		if (!this._updateSizeNeeded) {
			if (name === 'newBoundingBox')
				this._enableSizeUpdate()
		}
		$core.Item.prototype.on.apply(this, arguments)
	}

	///@private
	function _updateStyle() {
		if (this.shadow && !this.shadow._empty())
			this.style('text-shadow', this.shadow._getFilterStyle())
		else
			this.style('text-shadow', '')
		$core.Item.prototype._updateStyle.apply(this, arguments)
	}

	///@private
	function _enableSizeUpdate() {
		this._updateSizeNeeded = true
		this._updateSize()
	}

	onRecursiveVisibleChanged: {
		if (value && !this.offlineLayout)
			this._updateSize()
	}

	///@private
	function _updateSize() {
		if ((this.offlineLayout || this.recursiveVisible) && (this._updateSizeNeeded || this.clip))
			this._scheduleUpdateSize()
	}

	///@private
	function _updateSizeImpl() {
		if (this.text.length === 0) {
			this.paintedWidth = 0
			this.paintedHeight = 0
			return
		}

		this._context.backend.layoutText(this)
	}

	onTextChanged:				{ this._setText(value); this._updateSize() }
	onColorChanged: 			{ this.style('color', $core.Color.normalize(value)) }
	onWidthChanged:				{ this._updateSize() }
	onHeightChanged:			{ this._updateSize() }

	onVerticalAlignmentChanged: {
		this._enableSizeUpdate()
		if ($manifest$requireVerticalTextAlignmentStyle) {
			switch(value) {
				case this.AlignTop:		this.style('-pure-text-vertical-align', 'top'); break
				case this.AlignVCenter:	this.style('-pure-text-vertical-align', 'middle'); break
				case this.AlignBottom:	this.style('-pure-text-vertical-align', 'bottom'); break
			}
		}
	}

	onHorizontalAlignmentChanged: {
		switch(value) {
		case this.AlignLeft:	this.style('text-align', 'left'); break
		case this.AlignRight:	this.style('text-align', 'right'); break
		case this.AlignHCenter:	this.style('text-align', 'center'); break
		case this.AlignJustify:	this.style('text-align', 'justify'); break
		}
	}

	function _updateWSHandling() {
		var text = this.textFormat === this.Text
		switch(this.wrapMode) {
		case this.NoWrap:
			this.style({'white-space': text? 'pre': 'nowrap', 'word-break': '' })
			break
		case this.Wrap:
		case this.WordWrap:
			this.style({'white-space': text? 'pre-wrap': 'normal', 'word-break': '' })
			break
		case this.WrapAnywhere:
			this.style({ 'white-space': text? 'pre-wrap': 'normal', 'word-break': 'break-all' })
			break
		}
		this._updateSize();
	}

	onTextFormatChanged: {
		this._updateWSHandling()
	}

	onWrapModeChanged: {
		this._updateWSHandling()
	}

	onOfflineLayoutChanged: {
		if (value)
			this._enableSizeUpdate()
	}
}
