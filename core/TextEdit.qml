Item {
	property string text;
	focus: true;

	onCompleted: {
		var self = this;
		this.element.change(function() { self.text = self.element.val(); })
	}

	onTextChanged: { console.log("TEXT", this.text); }
}
