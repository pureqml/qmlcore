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
	property string cursorUrl: "res/mouse.png";

	onContainsMouseChanged: {
		if (value) {
			this.element.css('cursor', 'url("' + this.cursorUrl + '"), auto' );
			this.entered()
		} else {
			this.element.css('cursor', 'default');
			this.exited()
		}
	}

	onRecursiveVisibleChanged: {
		if (!value)
			this.containsMouse = false
	}
}
