Item {
	height: 20;
	width: 173;
	property string text;
	property bool passwordMode: false;

	onCompleted: {
		var input = $('<input>');
		input.width(this.width);
		input.height(this.height);
		input[0].type = this.passwordMode ? "password" : "text"
		var self = this
		input.keyup(function() { self.text = this.value } );
		input.keydown(function(event) { if (self._processKey(event)) event.preventDefault();} );
		this.element.append(input)
	}
}
