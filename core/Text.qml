Item {
	property string text;
	property color color;

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

	property int paintedWidth;
	property int paintedHeight;

	width: paintedWidth;
	height: paintedHeight;

	constructor: {
		this.element.addClass('text')
		var self = this
		this._delayedUpdateSize = new qml.core.DelayedAction(function() {
			self._updateSizeImpl()
		})
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
		qml.core.Object.prototype.onChanged.apply(this, arguments);
	}

	function on(name, callback) {
		if (!this._updateSizeNeeded) {
			if (name == 'boxChanged')
				this._enableSizeUpdate()
		}
		qml.core.Object.prototype.on.apply(this, arguments)
	}

	function _enableSizeUpdate() {
		this._updateSizeNeeded = true
		this._updateSize()
	}

	function _updateSize() {
		if (this._updateSizeNeeded)
			this._delayedUpdateSize.schedule()
	}

	function _reflectSize() {
		var dom = this.element[0]
		this.paintedWidth = dom.offsetWidth
		this.paintedHeight = dom.offsetHeight
	}

	function _updateSizeImpl() {
		if (this.text.length === 0) {
			this.paintedWidth = 0
			this.paintedHeight = 0
			return
		}

		var wrap = this.wrapMode != Text.NoWrap
		if (!wrap)
			this.style({ width: 'auto', height: 'auto' }) //no need to reset it to width, it's already there
		else
			this.style('height', 'auto')

		this._reflectSize()

		var style
		if (!wrap)
			style = { width: this.width, height: this.height }
		else
			style = {'height': this.height }

		switch(this.verticalAlignment) {
		case this.AlignTop:		style['margin-top'] = 0; break
		case this.AlignBottom:	style['margin-top'] = this.height - this.paintedHeight; break
		case this.AlignVCenter:	style['margin-top'] = (this.height - this.paintedHeight) / 2; break
		}
		this.style(style)
	}

	function _update(name, value) {
		var htmlRe = /[&<]/

		switch(name) {
			case 'text': if (htmlRe.exec(value)) this.element.html(value); else this.element.text(value); this._updateSize(); break;
			case 'color': this.style('color', qml.core.normalizeColor(value)); break;
			case 'width': this._updateSize(); break;
			case 'verticalAlignment': this.verticalAlignment = value; this._updateSize(); break
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
				case this.NoWrap:		this.style('white-space', 'nowrap'); break
				case this.WordWrap:		this.style('white-space', 'normal'); break
				case this.WrapAnywhere:	this.style('white-space', 'nowrap'); break	//TODO: implement.
				case this.Wrap:			this.style('white-space', 'nowrap'); break	//TODO: implement.
				}
				this._updateSize();
				break
		}
		qml.core.Item.prototype._update.apply(this, arguments);
	}
}
