Item {
	height: 20;
	width: 173;
	property string text;

	onCompleted: {
		var input = $('<input type="text">');
		input.width(this.width);
		input.height(this.height);
		var self = this
		input.keyup(function() { self.text = this.value } );
		input.keydown(function(event) { if (self._processKey(event)) event.preventDefault();} );
		this.element.append(input)
	}
}
