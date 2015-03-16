FocusablePanel {
	signal triggered;
	clip: true;

	onSelectPressed: { this.triggered(); }
	onClicked: { this.triggered(); }	
}