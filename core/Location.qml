Object {
	property string hash;
	property string host;
	property string href;
	property string port;
	property string origin;
	property string hostname;
	property string pathname;
	property string historyState;

	constructor: {
		var self = this
		var location = window.location
		window.onhashchange = function() { self.hash = location.hash }
	}

	updateActualValues: {
		this.hash = window.location.hash
		this.host = window.location.host
		this.href = window.location.href
		this.port = window.location.port
		this.origin = window.location.origin
		this.hostname = window.location.hostname
		this.pathname = window.location.pathname

		var state = window.history.state
		this.historyState = (typeof state === "string") ? state : JSON.stringify(state)
	}

	changeHref(href): {
		window.location.href = href
		this.updateActualValues()
	}

	pushState(state, title, url): {
		window.history.pushState(state, title, url)
		this.updateActualValues()
	}
}
