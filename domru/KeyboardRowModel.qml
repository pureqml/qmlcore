ListModel {
	property int begin;
	property int end;
	property Object parentModel;

	onCompleted: {
		var letters = this.parentModel.letters;
		var last = letters.length > this.end ? this.end : letters.length;
		for (var i = this.begin; i < last; ++i)
			this.append({ text: letters[i] });

		if (last == this.end - 4) {
			this.append({ icon: "res/backspace.png", contextColor: "#f33", widthScale: 2 });
			this.append({ text: " ", icon: "res/space.png", contextColor: "#33f", widthScale: 2 });
		} else if (this.end > letters.length) {
			this.append({ text: "@", widthScale: 2 });
			this.append({ text: ".com", widthScale: 3 });
			this.append({ text: ".ru", widthScale: 2 });
		}
	}
}


