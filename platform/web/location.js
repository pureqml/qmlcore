var Location = function(ui) {
	this._ui = ui
	var location = window.location
	this.updateActualValues()
	var self = this
	var context = ui._context
	context.window.on("hashchange", function() { self._ui.hash = location.hash }.bind(this))
	context.window.on("popstate", function() { self.updateActualValues() }.bind(this))
}

Device.prototype.updateActualValues(): {
	var ui = this._ui
	var windowContext = ui._context.window
	ui.hash = windowContext.location.hash
	ui.href = windowContext.location.href
	ui.port = windowContext.location.port
	ui.host = windowContext.location.host
	ui.origin = windowContext.location.origin
	ui.hostname = windowContext.location.hostname
	ui.pathname = windowContext.location.pathname
	ui.protocol = windowContext.location.protocol
	ui.search = windowContext.location.search
	ui.state = windowContext.history.state
}

Device.prototype.changeHref(href): {
	this._ui._context.window.location.href = href
	this.updateActualValues()
}

Device.prototype.pushState(state, title, url): {
	var ui = this._ui
	var windowContext = ui._context.window
	if (windowContext.location.hostname) {
		windowContext.history.pushState(state, title, url)
		this.updateActualValues()
	} else {
		ui._context.document.title = title
		this.state = state
	}
}


exports.createDevice = function(ui) {
	return new Location(ui)
}

exports.Location = Location
