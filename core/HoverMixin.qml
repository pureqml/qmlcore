/// this mixin provides mouse hover events handling
BaseMouseMixin {
	property bool value;			///< is 'true' if item if hovered, 'false' otherwise

	///@private
	constructor: {
		this.element = this.parent.element;
		this.parent.style('cursor', this.cursor)
		this._bindHover(this.enabled)
		if (!exports.hasProperty(parent, "hovered"))
			exports.addProperty(parent, "bool", "hovered", false)
	}

	///@private
	function _bindHover(value) {
		if (value && !this._hmHoverBinder) {
			this._hmHoverBinder = new $core.EventBinder(this.parent.element)

			if (this._context.backend.capabilities.mouseEnterLeaveSupported) {
				this._hmHoverBinder.on('mouseenter', function() { this.value = this._trueUnlessTouchEvent() }.bind(this))
				this._hmHoverBinder.on('mouseleave', function() { this.value = false }.bind(this))
			} else {
				this._hmHoverBinder.on('mouseover', function() { this.value = this._trueUnlessTouchEvent() }.bind(this))
				this._hmHoverBinder.on('mouseout', function() { this.value = false }.bind(this))
			}
			this._hmHoverBinder.on('touchstart', this._setTouchEvent.bind(this))
			this._hmHoverBinder.on('mouseup', this._resetTouchEvent.bind(this))
		}
		if (this._hmHoverBinder)
			this._hmHoverBinder.enable(value)
	}

	onValueChanged: { this.parent.hovered = value }
	onEnabledChanged: { this._bindHover(value) }
}
