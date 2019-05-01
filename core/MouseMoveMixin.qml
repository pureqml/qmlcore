/// this mixin provides mouse press events handling
Object {
	property bool enabled: true;	///< enable/disable mixin
	property int mouseX;
	property int mouseY;
	signal mouseMove;

	///@private
	constructor: {
		this.element = this.parent.element;
		this._bindMove(this.enabled)
	}

	/// @private
	function _updatePosition(event) {
		var parent = this.parent
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
				if (!this._updatePosition(event))
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
