Object {
	constructor: {
		var context = this._context
		var options = context.options

		var style = this.style = context.createElement('style')
		style.dom.type = 'text/css'

		var prefix = this.prefix = options.prefix
		var divId = options.id

		var div = document.getElementById(divId)
		var topLevel = div === null

		var userSelect = window.Modernizr.prefixedCSS('user-select') + ": none; "
		style.setHtml(
			"div#" + divId + " { position: absolute; visibility: inherit; left: 0px; top: 0px; }" +
			"div." + this._context.getClass('core-text') + " { width: auto; height: auto; visibility: inherit; }" +
			(topLevel? "body { overflow-x: hidden; }": "") + //fixme: do we need style here in non-top-level mode?
			this.mangleRule('video', "{ position: absolute; visibility: inherit; }") +
			this.mangleRule('img', "{ position: absolute; visibility: inherit; -webkit-touch-callout: none; " + userSelect + " }")
		)
		_globals.html5.html.getElement('head').append(style)

		this._addRule = _globals.html5.html.createAddRule(style.dom)
	}
	
	function mangleSelector(selector) {
		var prefix = this.prefix
		if (prefix)
			return selector + '.' + prefix + 'core-item'
		else
			return selector
	}

	function mangleRule(selector, rule) {
		return this.mangleSelector(selector) + ' ' + rule + ' '
	}

	function addRule(selector, rule) {
		var mangledSelector = this.mangleSelector(selector)
		this._addRule(mangledSelector, rule)
	}

}
