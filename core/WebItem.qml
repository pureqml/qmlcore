Rectangle {
	signal clicked;
	color: "transparent";

	property bool hover;
	property string cursor;

	onCursorChanged: {
		this.element.css('cursor', value);
	}
}