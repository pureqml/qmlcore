/// object for storing value by key name
Object {
	property string name;		///< stored property key name
	property string value;		///< stored property value

	constructor: {
		this.impl = null
		this._createLocalStorage()
	}

	/// @private
	function _getImpl() {
		if (this.impl === null)
			this._createLocalStorage()
		return this.impl
	}

	function _createLocalStorage() {
		if (this.impl) {
			return this.impl
		} else {
			var backend = _globals.core.__localStorageBackend
			return this.impl = backend().createLocalStorage(this)
		}
	}

	getItem(name): {
		var impl = this._getImpl()
		return impl ? impl.getItem(name) : null
	}

	read: {
		var impl = this._getImpl()
		if (impl)
			impl.read()
	}

	///@private
	onValueChanged: {
		var impl = this._getImpl()
		if (impl)
			impl.saveItem()
	}

	///@private
	onNameChanged: { this.read() }

	///@private
	onCompleted: { this.read() }
}
