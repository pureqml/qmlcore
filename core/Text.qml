Item {
	property string text;		///< text to be displayed
	property color color;		///< color of the text
	property Shadow shadow: Shadow { }

	property enum wrapMode {
		NoWrap, WordWrap, WrapAnywhere, Wrap
	};

	property enum horizontalAlignment {
		AlignLeft, AlignRight, AlignHCenter, AlignJustify
	};

	property enum verticalAlignment {
		AlignTop, AlignBottom, AlignVCenter
	};

	property Font font: Font {}

	property int paintedWidth;		///< real width of the text without any layout applied
	property int paintedHeight;		///< real height of this text without any layout applied

	width: paintedWidth;
	height: paintedHeight;

	constructor: {
		this._context.backend.initText(this)
		this._setText(this.text)
		var self = this
		this._delayedUpdateSize = new _globals.core.DelayedAction(this._context, function() {
			self._updateSizeImpl()
		})
	}

	function _setText(html) {
		this.element.setHtml(html)
	}

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
		_globals.core.Object.prototype.onChanged.apply(this, arguments);
	}

	function on(name, callback) {
		if (!this._updateSizeNeeded) {
			if (name == 'boxChanged')
				this._enableSizeUpdate()
		}
		_globals.core.Object.prototype.on.apply(this, arguments)
	}

	function _updateStyle() {
		if (this.shadow && !this.shadow._empty())
			this.style('text-shadow', this.shadow._getFilterStyle())
		else
			this.style('text-shadow', '')
		_globals.core.Item.prototype._updateStyle.apply(this, arguments)
	}

	function _enableSizeUpdate() {
		this._updateSizeNeeded = true
		this._updateSize()
	}

	function _updateSize() {
		if (this._updateSizeNeeded)
			this._delayedUpdateSize.schedule()
	}

	function _updateSizeImpl() {
		if (this.text.length === 0) {
			this.paintedWidth = 0
			this.paintedHeight = 0
			return
		}

		this._context.backend.layoutText(this)
	}

	function _update(name, value) {
		switch(name) {
			case 'text': this._setText(value); this._updateSize(); break;
			case 'color': this.style('color', _globals.core.normalizeColor(value)); break;
			case 'width': this._updateSize(); break;
			case 'verticalAlignment': this.verticalAlignment = value; this._enableSizeUpdate(); break
			case 'horizontalAlignment':
				switch(value) {
				case this.AlignLeft:	this.style('text-align', 'left'); break
				case this.AlignRight:	this.style('text-align', 'right'); break
				case this.AlignHCenter:	this.style('text-align', 'center'); break
				case this.AlignJustify:	this.style('text-align', 'justify'); break
				}
				break
			case 'wrapMode':
				switch(value) {
				case this.NoWrap:
					this.style({'white-space': 'nowrap', 'word-break': '' })
					break
				case this.Wrap:
				case this.WordWrap:
					this.style({'white-space': 'normal', 'word-break': '' })
					break
				case this.WrapAnywhere:
					this.style({ 'white-space': 'normal', 'word-break': 'break-all' })
					break
				}
				this._updateSize();
				break
		}
		_globals.core.Item.prototype._update.apply(this, arguments);
	}
}
