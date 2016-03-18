Item {
	property string text;
	property color color;

	property bool wrap;
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

	onCompleted: {
		if (!this._allowLayout) { 
			this._allowLayout = true;
			this._updateSize();
		}
	}
}
