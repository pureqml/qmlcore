Item {
	property string text;
	focus: true;

	onTextChanged: { console.log("TEXT", this.text); }
}
