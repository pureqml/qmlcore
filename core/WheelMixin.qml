/// mixin for wheel events
Object {
	property bool enabled: true;	///< enable mixin

	///@private
	constructor: {
		this.element = this.parent.element;
		this._bindWheel(this.enabled)
	}

	///@private
	function _bindWheel(value) {
		if (value && !this._wheelBinder) {
			this._wheelBinder = new $ns$core.EventBinder(this.parent.element)
			this._wheelBinder.on('wheel', $ns$core.createSignalForwarder(this.parent, 'wheel').bind(this))
			this._wheelBinder.on('mousewheel', $ns$core.createSignalForwarder(this.parent, 'wheel').bind(this))
		}
		if (this._wheelBinder)
			this._wheelBinder.enable(value)
	}

	///@private
	onEnabledChanged: { this._bindWheel(value) }
}
