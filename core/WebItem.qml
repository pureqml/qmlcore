Rectangle {
	signal clicked;
	property bool hover;
	property bool clickable: true;
	property bool hoverable: true;
	property string cursor : "pointer";
	color: "transparent";

	constructor:		{ this.style('cursor', this.cursor) }
	onCursorChanged: 	{ this.style('cursor', value) }

	onClickableChanged: {
		if (value)
			this.element.click(this.clicked.bind(this))
		else
			this.element.unbind('click')
	}

	onHoverableChanged: {
		var self = this
		if (value)
			this.element.hover(function() { self.hover = true }, function() { self.hover = false })
		else
			this.element.unbind('mouseenter mouseleave')
	}

	onCompleted: {
		var self = this
		if (this.clickable)
			this.element.click(this.clicked.bind(this))
		if (this.hoverable)
			this.element.hover(function() { self.hover = true }, function() { self.hover = false })
	}
}
