/// this mixin provides mouse press events handling
Object {
	property bool enabled: true;	///< enable/disable mixin
	property bool pressed;			///< true if any buttons pressed

	///@private
	constructor: {
		this.element = this.parent.element;
		this._bindPress(this.enabled)
	}

	/// @private
	function _bindPress(value) {
		if (value && !this._mpmPressBinder) {
			this._mpmPressBinder = new $ns$core.EventBinder(this.element)
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
