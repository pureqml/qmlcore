Item {
	height: 20;
	width: 173;
	property string text;
	property bool passwordMode: false;
	property Color color: "#000000";
	property Color backgroundColor: "#fff";

	onCompleted: {
		var input = document.createElement("input");
		input.setAttribute("type", this.passwordMode ? "password" : "text");
		input.style.width = this.width + "px"
		input.style.height = this.height + "px"
		input.style.color = this.color
		input.style.background = this.backgroundColor

		var self = this
		input.onkeyup = function() { self.text = this.value }
		input.onkeydown = function(event) { if (self._processKey(event)) event.preventDefault();}

		this.element.append(input)
	}
}
