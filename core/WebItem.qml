Rectangle {
	signal clicked;
	property bool hover;
	property bool clickable: true;
	property bool hoverable: true;
	property string cursor : "pointer";
	color: "transparent";

	constructor:		{ this.style('cursor', this.cursor) }
	onCursorChanged: 	{ this.style('cursor', value) }

	function _bindClick(value) {
		if (value && !this._clickBinder) {
			this._clickBinder = new _globals.core.EventBinder(this.element)
			this._clickBinder.on('click', this.clicked.bind(this))
		}
		this._clickBinder.enable(value)
	}

	onClickableChanged: {
		this._bindClick(value)
	}

	function _bindHover(value) {
		if (value && !this._hoverBinder) {
			this._hoverBinder = new _globals.core.EventBinder(this.element)
			this._hoverBinder.on('mouseenter', function() { this.hover = true }.bind(this))
			this._hoverBinder.on('mouseleave', function() { this.hover = false }.bind(this))
		}
		if (this._hoverBinder)
			this._hoverBinder.enable(value)
	}

	onHoverableChanged: {
		this._bindHover(value)
	}

	onCompleted: {
		this._bindClick(this.clickable)
		this._bindHover(this.hoverable)
	}
}
