Item {
	property Font font: Font {}
	property color textColor;

	property string text;
	property bool readOnly;

	width: 150;
	height: 100;

	onCompleted: {
		var textarea = $('<textarea>')
		textarea.width(this.width)
		textarea.height(this.height)
		var self = this
		textarea.change(function() { self.text = this.value })
		this.element.append(textarea)
	}
}
