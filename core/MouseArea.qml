Item {
	signal entered;
	signal exited;
	signal clicked;

	property bool hoverEnabled;
	property bool hovered;
	property real mouseX;
	property real mouseY;

	onHoveredChanged: {
		if (this.hovered)
			this.entered()
		else
			this.exited()
	}
}
