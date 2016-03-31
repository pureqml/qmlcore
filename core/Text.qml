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
	}

	onCompleted: {
		if (!this._allowLayout) { 
			this._allowLayout = true;
			this._updateSize();
		}
	}
}
