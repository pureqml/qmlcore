FocusablePanel {
	signal triggered;
	clip: true;

	onSelectPressed: { 
		this.makeBlink();
		this.triggered(); 
	}

	onClicked: { 
		this.makeBlink();
		this.triggered(); 
	}	
}