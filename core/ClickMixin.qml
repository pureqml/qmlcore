Object {
	property bool enabled: true;

	constructor: {
		this.element = this.parent.element;
		this._bindClick(this.enabled)
	}

	function _bindClick(value) {
		if (value && !this._cmClickBinder) {
			this._cmClickBinder = new _globals.core.EventBinder(this.element)
			this._cmClickBinder.on('click', _globals.core.createSignalForwarder(this.parent, 'clicked').bind(this))
		}
		if (this._cmClickBinder)
			this._cmClickBinder.enable(value)
	}

	onEnabledChanged: { this._bindClick(value) }
}
