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
		var backend = $core.__locationBackend
		if (!backend)
			throw new Error('no backend found')
		this.impl = backend().createLocation(this)
	}

	pushState(state, title, url): {
		this.impl.pushState(state, title, url)
	}

	changeHref(href): {
		this.impl.changeHref(href)
	}

	function reload() {
		this.impl.reload()
	}
}
