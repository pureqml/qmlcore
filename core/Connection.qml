/// Describes generalized connections to signals. However it's preferrable to use extended syntax, e.g. `myButton.onClicked: { }` instead of dynamic Connection. This class is useful if you want to switch your targets on the fly
Object {
	property Object target; ///< target object to connect to

	constructor: {
		this._declaredOnConnections = []
		this._declaredOnChangedConnections = []
	}

	/// @private
	function _disconnect() {
		this.removeAllOn()
		this.removeAllOnChanged()
	}

	/// @private
	function _reconnect() {
		this._disconnect()

		var target = this.target
		if (!target)
			return

		if (!(target instanceof $core.CoreObject))
			throw new Error("You can only assign qml objects to target, got: " + target + " of type " + typeof target + " to " + this.getComponentPath())

		//reconnect onTargetChanged
		this.connectOnChanged(this, 'target', this._scheduleReconnect.bind(this)) //restore target connection


		var ons = this._declaredOnConnections
		for(var i = 0, n = ons.length; i < n; i += 2) {
			this.connectOn(this.target, ons[i], ons[i + 1])
		}
		ons = this._declaredOnChangedConnections
		for(var i = 0, n = ons.length; i < n; i += 2) {
			this.connectOnChanged(this.target, ons[i], ons[i + 1])
		}
	}

	/// @private
	function _scheduleReconnect() {
		this._context.delayedAction('reconnect', this, this._reconnect)
	}

	/// @private
	function on (name, callback) {
		if (name === 'target')
			return

		if (name === '')
			throw new Error('empty listener name')

		this._declaredOnConnections.push(name, callback)
		if (this.target) {
			this.connectOn(this.target, name, callback)
		}
	}

	/// @private
	function onChanged (name, callback) {
		if (name === 'target')
			return

		if (name === '')
			throw new Error('empty listener name')

		this._declaredOnChangedConnections.push(name, callback)
		if (this.target)
			this.connectOnChanged(this.target, name, callback)
	}

	onTargetChanged,
	onCompleted:
	{ this._scheduleReconnect(); }
}
