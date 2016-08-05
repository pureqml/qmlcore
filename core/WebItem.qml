Rectangle {
	signal clicked;
	property bool hover;
	property bool clickable: true;
	property bool hoverable: true;
	property string cursor : "pointer";
	color: "transparent";

	constructor:		{ this.style('cursor', this.cursor) }
	onCursorChanged: 	{ this.style('cursor', value) }

	function _bindClick() {
		if (!this._clicked)
			this._clicked = this.clicked.bind(this)
		this.element.on('click', this._clicked)
	}

	onClickableChanged: {
		if (value)
			this._bindClick()
		else
			this.element.removeListener('click', this._clicked)
	}

	function _bindHover(value) {
		var self = this
		var onEnter = function() { self.hover = true }
		var onLeave = function() { self.hover = false }
		if (value) {
			this.element.on('mouseenter', onEnter)
			this.element.on('mouseleave', onLeave)
		} else {
			this.element.removeListener('mouseenter', onEnter)
			this.element.removeListener('mouseleave', onLeave)
		}
	}

	onHoverableChanged: {
		this._bindHover(value)
	}

	onCompleted: {
		var self = this
		if (this.clickable)
			this._bindClick()
		if (this.hoverable)
			this._bindHover(true)
	}
}
