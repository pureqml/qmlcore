Item {
	property string text;
	property color color;

	property bool wrap;
	property int horizontalAlignment;
	property int verticalAlignment;

	property Font font: Font {}
	property int paintedWidth;
	property int paintedHeight;

	width: paintedWidth;
	height: paintedHeight;

	onCompleted: {
		if (this.text.length > 0 && !this._allowLayout) { 
			this._allowLayout = true;
			this._updateSize();
		}
	}
}
