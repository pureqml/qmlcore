/// simple proxy to underlying storage
Object {
	constructor: {
		var backend = $core.__localStorageBackend
		this.impl = backend().createLocalStorage(this)
	}

	///@private
	_checkNameValid(name): {
		if (!name) throw new Error("empty name")
	}

	///@private
	_ensureCallback(cb, name): {
		return cb || function(val) { log("ignore value of", name, "gotten from storage:", val) }
	}

	///@private
	_ensureErrCallback(cb): {
		return cb || function(err) { log(err.message) }
	}

	/**
	 * Return stored item by name
	 * @param {string} name - stored item name
	 * @param {function} callback - callback to return value
	 * @param {function} error - callback to report non-existing value or some kind of error
	 */
	get(name, callback, error): {
		this._checkNameValid(name)
		this.impl.get(name, this._ensureCallback(callback, name), this._ensureErrCallback(error), this)
	}

	/**
	 * Return stored item by name or default value if not exists
	 * @param {string} name - stored item name
	 * @param {function} callback - callback to return value
	 * @param {Object} defaultValue - default value
	 */
	getOrDefault(name, callback, defaultValue): {
		this._checkNameValid(name)
		callback = this._ensureCallback(callback, name)
		this.impl.get(name, callback, function() { callback(defaultValue) }, this)
	}

	/**
	 * Save named item
	 * @param {string} name - item name
	 * @param {string} value - item value
	 * @param {function} error - callback to report error
	 */
	set(name, value, error): {
		this._checkNameValid(name)
		this.impl.set(name, value, this._ensureErrCallback(error), this)
	}

	/**
	 * Remove item
	 * @param {string} name - item name
	 * @param {function} error - callback to report error
	 */
	erase(name, error): {
		this._checkNameValid(name)
		this.impl.erase(name, this._ensureErrCallback(error), this)
	}
}
