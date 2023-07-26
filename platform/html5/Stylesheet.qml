Object {
	constructor: {
		var context = this._context

		var style = this.style = context.createElement('style')
		style.dom.type = 'text/css'

		var divId = context.options.id

		var div = document.getElementById(context, divId)
		var topLevel = div === null

		var tapHighlighted = context.system.tapHighlighted

		//var textAdjust = window.Modernizr.prefixedCSS('text-size-adjust') + ": 100%; "
		style.setHtml(
			//"html { " + textAdjust + " }" +
			"div#" + divId + " { position: absolute; visibility: hidden; left: 0px; top: 0px; }" +
			(tapHighlighted ? this.mangleRule('div', "{ -webkit-tap-highlight-color: rgba(255, 255, 255, 0); -webkit-focus-ring-color: rgba(255, 255, 255, 0); outline: none; }") : "") +
			(topLevel? "body { padding: 0; margin: 0; border: 0px; overflow: hidden; }": "") + //fixme: do we need style here in non-top-level mode?
			this.mangleRule('video', "{ position: absolute; }") + //fixme: do we need position rule if it's item?
			this.mangleRule('img', "{ position: absolute; -webkit-touch-callout: none; }")
		)
		var head = _globals.html5.html.getElement(context, 'head')
		head.append(style)
		head.updateStyle()

		this._addRule = _globals.html5.html.createAddRule(style.dom).bind(this)
		this._lastId = 0
	}

	function allocateClass(prefix) {
		var globalPrefix = $manifest$html5$prefix
		return (globalPrefix? globalPrefix: '') + prefix + '-' + this._lastId++
	}

	function mangleSelector(selector) {
		var prefix = $manifest$html5$prefix
		if (prefix)
			return selector + '.' + prefix + 'core-item'
		else
			return selector
	}

	function mangleRule(selector, rule) {
		return this.mangleSelector(selector) + ' ' + rule + ' '
	}

	function addRule(selector, rule) {
		this._addRule(selector, rule)
	}

}
