Object {
	signal wheel;
	property bool enabled: true;

	constructor: {
		this.element = this.parent.element;
		this._bindWheel(this.enabled)
	}

	function _bindWheel(value) {
		if (value && !this._wheelBinder) {
			this._wheelBinder = new _globals.core.EventBinder(this.parent.element)
			this._wheelBinder.on('wheel', _globals.core.createSignalForwarder(this.parent, 'wheel').bind(this))
		}
		if (this._wheelBinder)
			this._wheelBinder.enable(value)
	}

	onEnabledChanged: { this._bindWheel(value) }
}
