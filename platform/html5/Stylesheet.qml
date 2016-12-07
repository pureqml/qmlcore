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
			this.mangleRule('div', "{ position: absolute; visibility: inherit; border-style: solid; border-width: 0px; white-space: nowrap; border-radius: 0px; opacity: 1.0; transform: none; left: 0px; top: 0px; width: 0px; height: 0px; }") +
			this.mangleRule('a', "{ position: absolute; visibility: inherit; border-style: solid; border-width: 0px; white-space: nowrap; border-radius: 0px; opacity: 1.0; transform: none; left: 0px; top: 0px; width: 0px; height: 0px; }") +
			this.mangleRule('textarea', "{ position: absolute; visibility: inherit; border-style: solid; border-width: 0px; box-sizing: border-box; resize: none; }") +
			this.mangleRule('textarea:focus', "{outline: none;}") +
			this.mangleRule('button', "{ position: absolute; visibility: inherit; }") +
			this.mangleRule('canvas', "{ position: absolute; visibility: inherit; }") +
			this.mangleRule('video', "{ position: absolute; visibility: inherit; }") +
			this.mangleRule('svg', "{ position: absolute; visibility: inherit; overflow: visible; }") +
			this.mangleRule('pre', "{ position: absolute; visibility: inherit; margin: 0px;}") +
			this.mangleRule('select', "{ position: absolute; visibility: inherit; margin: 0px;}") +
			this.mangleRule('h1', "{ position: absolute; visibility: inherit; margin: 0px;}") +
			this.mangleRule('h2', "{ position: absolute; visibility: inherit; margin: 0px;}") +
			this.mangleRule('h3', "{ position: absolute; visibility: inherit; margin: 0px;}") +
			this.mangleRule('h4', "{ position: absolute; visibility: inherit; margin: 0px;}") +
			this.mangleRule('h5', "{ position: absolute; visibility: inherit; margin: 0px;}") +
			this.mangleRule('h6', "{ position: absolute; visibility: inherit; margin: 0px;}") +
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
