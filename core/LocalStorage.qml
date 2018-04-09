/// simple proxy to underlying storage
Object {
	constructor: {
		var backend = _globals.core.__localStorageBackend
		this.impl = backend().createLocalStorage()
	}

	/**
	 * Return stored item by name
	 * @param {string} name - stored item name
	 * @param {function} callback - callback to return value
	 * @param {function} error - callback to report non-existing value or some kind of error
	 */
	get(name, callback, error): {
		this.impl.get(name, callback, error)
	}

	/**
	 * Return stored item by name or default value if not exists
	 * @param {string} name - stored item name
	 * @param {function} callback - callback to return value
	 * @param {Object} defaultValue - default value
	 */
	getOrDefault(name, callback, defaultValue): {
		this.impl.get(name, callback, function() { callback(defaultValue) })
	}

	/**
	 * Save named item
	 * @param {string} name - item name
	 * @param {string} value - item value
	 */
	set(name, value, error): {
		this.impl.set(name, value, error)
	}

	/**
	 * Remove item
	 * @param {string} name - item name
	 * @param {function} error - callback to report error
	 */
	erase(name, error): {
		this.impl.erase(name, error)
	}
}
