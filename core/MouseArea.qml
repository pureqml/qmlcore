Item {
	signal entered;
	signal exited;
	signal clicked;
	signal canceled;
	signal wheelEvent;

	property bool hoverEnabled;
	property bool containsMouse;
	property real mouseX;
	property real mouseY;
	property bool pressed;

	onContainsMouseChanged: {
		if (value)
			this.entered()
		else
			this.exited()
	}

	onRecursiveVisibleChanged: {
		if (!value)
			this.containsMouse = false
	}
}
