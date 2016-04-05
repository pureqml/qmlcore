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
	onCompleted: { this._updateSize() }
}
