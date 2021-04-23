/// this mixin provides mouse press events handling
BaseMouseMixin {
	property int mouseX;
	property int mouseY;
	property int clientX;
	property int clientY;
	property int screenX;
	property int screenY;
	signal mouseMove;

	///@private
	constructor: {
		this.element = this.parent.element;
		this._bindMove(this.enabled)
	}

	/// @private
	function _updatePosition(event) {
		var parent = this.parent
		this.screenX = event.screenX;
		this.screenY = event.screenY;
		this.clientX = event.clientX;
		this.clientY = event.clientY;
		var x = event.offsetX
		var y = event.offsetY
		if (x >= 0 && y >= 0 && x < parent.width && y < parent.height) {
			this.mouseX = x
			this.mouseY = y
			this.mouseMove(x, y)
			return true
		}
		else
			return false
	}

	/// @private
	function _bindMove(value) {
		if (value && !this._mouseMoveBinder) {
			this._mouseMoveBinder = new $core.EventBinder(this.element)
			this._mouseMoveBinder.on('mousemove', function(event) {
				if (!this._updatePosition(event) && ('preventDefault' in event))
					event.preventDefault()
			}.bind(this))
		}
		if (this._mouseMoveBinder)
			this._mouseMoveBinder.enable(value)
	}

	onEnabledChanged: {
		this._bindMove(value)
	}
}
