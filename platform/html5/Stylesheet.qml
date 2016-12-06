Object {
	constructor: {
		var context = this._context
		var options = context.options

		var style = this.style = context.createElement('style')

		var prefix = options.prefix
		var divId = options.id

		var userSelect = window.Modernizr.prefixedCSS('user-select') + ": none; "
		var mangleRule = function(selector, rule) {
			if (prefix)
				return selector + '.' + prefix + 'core-item ' + rule + ' '
			else
				return selector + ' ' + rule + ' '
		}

		var div = document.getElementById(divId)
		var topLevel = div === null

		style.setHtml(
			"div#" + divId + " { position: absolute; visibility: inherit; left: 0px; top: 0px; }" +
			"div." + this._context.getClass('core-text') + " { width: auto; height: auto; visibility: inherit; }" +
			(topLevel? "body { overflow-x: hidden; }": "") + //fixme: do we need style here in non-top-level mode?
			mangleRule('div', "{ position: absolute; visibility: inherit; border-style: solid; border-width: 0px; white-space: nowrap; border-radius: 0px; opacity: 1.0; transform: none; left: 0px; top: 0px; width: 0px; height: 0px; }") +
			mangleRule('a', "{ position: absolute; visibility: inherit; border-style: solid; border-width: 0px; white-space: nowrap; border-radius: 0px; opacity: 1.0; transform: none; left: 0px; top: 0px; width: 0px; height: 0px; }") +
			mangleRule('textarea', "{ position: absolute; visibility: inherit; border-style: solid; border-width: 0px; box-sizing: border-box; resize: none; }") +
			mangleRule('textarea:focus', "{outline: none;}") +
			mangleRule('input', "{ position: absolute; visibility: inherit; border-style: solid; border-width: 0px; box-sizing: border-box; }") +
			mangleRule('input:focus', "{outline: none;}") +
			mangleRule('button', "{ position: absolute; visibility: inherit; }") +
			mangleRule('canvas', "{ position: absolute; visibility: inherit; }") +
			mangleRule('video', "{ position: absolute; visibility: inherit; }") +
			mangleRule('svg', "{ position: absolute; visibility: inherit; overflow: visible; }") +
			mangleRule('pre', "{ position: absolute; visibility: inherit; margin: 0px;}") +
			mangleRule('select', "{ position: absolute; visibility: inherit; margin: 0px;}") +
			mangleRule('h1', "{ position: absolute; visibility: inherit; margin: 0px;}") +
			mangleRule('h2', "{ position: absolute; visibility: inherit; margin: 0px;}") +
			mangleRule('h3', "{ position: absolute; visibility: inherit; margin: 0px;}") +
			mangleRule('h4', "{ position: absolute; visibility: inherit; margin: 0px;}") +
			mangleRule('h5', "{ position: absolute; visibility: inherit; margin: 0px;}") +
			mangleRule('h6', "{ position: absolute; visibility: inherit; margin: 0px;}") +
			mangleRule('img', "{ position: absolute; visibility: inherit; -webkit-touch-callout: none; " + userSelect + " }")
		)
		_globals.html5.html.getElement('head').append(style)
	}


}
