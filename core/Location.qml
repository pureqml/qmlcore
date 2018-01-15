/// Window location object
Object {
	property string hash;			///< contains current hash value (after '#' charachter)
	property string host;			///< current host with port number
	property string href;			///< whole current URL
	property string port;			///< current port number
	property string origin;			///< current protocol, hostname and port number of a URL
	property string hostname;		///< current host name
	property string pathname;		///< path name of the current URL
	property string protocol;		///< current protocol
	property string search;			///< query string of the URL
	property Object state;			///< current history state

	///@private
	constructor: {
		this.impl = null
		this._createLocation()
	}

	///@private
	function _getLocation() {
		if (this.impl === null)
			this._createPlayer()
		return this.impl
	}

	///@private
	function _createLocation() {
		if (this.impl)
			return this.impl

		var backend = _globals.core.__locationBackend
		if (!backend)
			throw new Error('no backend found')
		return this.impl = backend().createLocation(this)
	}

	pushState(state, title, url): {
		var location = this._getLocation()
		if (location)
			player.pushState(state, title, url)
	}

	changeHref(href): {
		var location = this._getLocation()
		if (location)
			player.changeHref(href)
	}
}
