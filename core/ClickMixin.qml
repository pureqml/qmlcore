/// This mixin provides mouse click event detecting
BaseMixin {
	///@private
	constructor: {
		this._bindClick(this.enabled)
	}

	///@private
	function _bindClick(value) {
		if (value && !this._cmClickBinder) {
			this._cmClickBinder = new $core.EventBinder(this.element)
			this._cmClickBinder.on('click', $core.createSignalForwarder(this.parent, 'clicked').bind(this))
		}
		if (this._cmClickBinder)
			this._cmClickBinder.enable(value)
	}

	///@private
	onEnabledChanged: { this._bindClick(value) }
}
