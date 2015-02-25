Item {
	signal entered;
	signal exited;
	signal clicked;

	property bool hoverEnabled;
	property bool containsMouse;
	property real mouseX;
	property real mouseY;
	property bool pressed;

	onContainsMouseChanged: {
		if (this.containsMouse)
			this.entered()
		else
			this.exited()
	}
}
