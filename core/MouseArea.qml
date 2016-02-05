Item {
	signal entered;
	signal exited;
	signal clicked;
	signal canceled;
	signal wheelEvent;
	signal verticalSwiped;
	signal horizontalSwiped;

	property bool hoverEnabled;
	property bool containsMouse;
	property real mouseX;
	property real mouseY;
	property bool pressed;
	property string cursor;
	property bool hover: containsMouse;

	onCursorChanged: {
		this.element.css('cursor', value);
	}

	onRecursiveVisibleChanged: {
		if (!value)
			this.containsMouse = false
	}
}
