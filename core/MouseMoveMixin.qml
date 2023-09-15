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
		this._bindMove(this.enabled)
	}

	/// @private
	function _updatePosition(event) {
		var parent = this.parent
		var touchEvent = event.type === 'touchmove'
		var x, y
		if (touchEvent) {
			var touch = event.touches[0]
			this.screenX = touch.screenX;
			this.screenY = touch.screenY;
			this.clientX = touch.clientX;
			this.clientY = touch.clientY;
			var screenPos = this.parent.toScreen()
			x = touch.clientX - screenPos[0]
			y = touch.clientY - screenPos[1]
		} else {
			this.screenX = event.screenX;
			this.screenY = event.screenY;
			this.clientX = event.clientX;
			this.clientY = event.clientY;
			x = event.offsetX
			y = event.offsetY
		}
		if (x >= 0 && y >= 0 && x < parent.width && y < parent.height) {
			this.mouseX = x
			this.mouseY = y
			this.mouseMove(x, y, event)
			return true
		}
		else
			return false
	}

	/// @private
	function _bindMove(value) {
		if (value && !this._mouseMoveBinder) {
			this._mouseMoveBinder = new $core.EventBinder(this.element)
			var handler = function(event) {
				if (this._updatePosition(event) && event.type !== 'touchmove')
					$core.callMethod(event, 'preventDefault')
			}.bind(this)
			this._mouseMoveBinder.on('mousemove', handler)
			this._mouseMoveBinder.on('touchmove', handler)
		}
		if (this._mouseMoveBinder)
			this._mouseMoveBinder.enable(value)
	}

	onEnabledChanged: {
		this._bindMove(value)
	}
}
