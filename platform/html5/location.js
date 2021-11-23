var Location = function(ui) {
	this._ui = ui
	var location = window.location
	this.updateActualValues()
	var self = this
	var context = ui._context
	context.window.on("hashchange", function() { self._ui.hash = location.hash }.bind(this))
	context.window.on("popstate", function() { self.updateActualValues() }.bind(this))
}

Location.prototype.updateActualValues = function() {
	var ui = this._ui
	var windowContext = ui._context.window.dom
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

Location.prototype.changeHref = function(href) {
	this._ui._context.window.dom.location.href = href
	this.updateActualValues()
}

Location.prototype.reload = function() {
	this._ui._context.window.dom.location.reload()
}

Location.prototype.pushState = function(state, title, url) {
	var ui = this._ui
	var windowContext = ui._context.window.dom
	if (windowContext.location.hostname) {
		windowContext.history.pushState(state, title, url)
		this.updateActualValues()
	} else {
		ui._context.document.title = title
		this._ui.state = state
	}
}

exports.createLocation = function(ui) {
	return new Location(ui)
}

exports.Location = Location
