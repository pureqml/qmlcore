Item {
	height: 20;
	width: 173;
	property string text;

	onCompleted: {
		var input = $('<input type="text">');
		this.element.append(input)

		var inputs = document.getElementsByTagName('INPUT');
		var self = this;
		var func = function() { 
			self.text = this.value;
		}

		inputs[inputs.length - 1].onkeyup = func;
	}
}
