Item {
	signal entered;
	signal exited;
	signal clicked;
	signal canceled;
	signal wheelEvent;
	signal verticalSwiped;

	property bool hoverEnabled;
	property bool containsMouse;
	property real mouseX;
	property real mouseY;
	property bool pressed;
	property bool defaultCursor: false;
	//property string cursorUrl: "res/mouse.png";
	property string cursorUrl: "";

	onContainsMouseChanged: {
		if (value) {
			if (this.cursorUrl)
				this.element.css('cursor', 'url("' + this.cursorUrl + '"), auto' );
			else if (!this.defaultCursor)
				this.element.css('cursor', 'pointer');
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

	onDefaultCursorChanged: {
		if (value)
			this.element.css('cursor', 'default');
		else
			this.element.css('cursor', 'pointer');	
	}
}
