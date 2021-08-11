/// this mixin provides mouse press events handling
BaseMouseMixin {
	property bool pressed;			///< true if any buttons pressed

	///@private
	constructor: {
		this._bindPress(this.enabled)
	}

	/// @private
	function _bindPress(value) {
		if (value && !this._mpmPressBinder) {
			this._mpmPressBinder = new $core.EventBinder(this.element)
			this._mpmPressBinder.on('mousedown',	function() { this.pressed = true }.bind(this))
			this._mpmPressBinder.on('mouseup',		function() { this.pressed = false }.bind(this))
		}
		if (this._mpmPressBinder)
			this._mpmPressBinder.enable(value)
	}

	/// @private
	onEnabledChanged: {
		this._bindPress(value)
	}
}
