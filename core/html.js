/**
 * @constructor
 */

var registerGenericListener = function(target) {
	var copyArguments = _globals.core.copyArguments
	target.onListener('',
		function(name) {
			//log('registering generic event', name)
			var callback = function() {
				var args = copyArguments(arguments, 0, name)
				target.emit.apply(target, args)
			}
			target.dom.addEventListener(name, callback)
		},
		function(name) {
			//fixme: implement removing callback
			//return remove callback from first callback?
		}
	)
}

exports.Element = function(context, dom) {
	_globals.core.EventEmitter.apply(this)
	this._context = context
	this.dom = dom
	this._fragment = []
	this._styles = {}

	registerGenericListener(this)
}

exports.Element.prototype = Object.create(_globals.core.EventEmitter.prototype)
exports.Element.prototype.constructor = exports.Element

exports.Element.prototype.addClass = function(cls) {
	this.dom.classList.add(cls)
}

exports.Element.prototype.setHtml = function(html) {
	var dom = this.dom
	this._fragment.forEach(function(node) { dom.removeChild(node) })
	this._fragment = []

	if (html === '')
		return

	var fragment = document.createDocumentFragment()
	var temp = document.createElement('div')

	temp.innerHTML = html
	while (temp.firstChild) {
		this._fragment.push(temp.firstChild)
		fragment.appendChild(temp.firstChild)
	}
	dom.appendChild(fragment)
	return dom.children
}

exports.Element.prototype.width = function() {
	return this.dom.clientWidth
}

exports.Element.prototype.height = function() {
	return this.dom.clientHeight
}

exports.Element.prototype.fullWidth = function() {
	return this.dom.scrollWidth
}

exports.Element.prototype.fullHeight = function() {
	return this.dom.scrollHeight
}

exports.Element.prototype.style = function(name, style) {
	if (style !== undefined) {
		if (style !== '') //fixme: replace it with explicit 'undefined' syntax
			this._styles[name] = style
		else
			delete this._styles[name]
		this.updateStyle()
	} else if (name instanceof Object) { //style({ }) assignment
		for(var k in name) {
			var value = name[k]
			if (value !== '') //fixme: replace it with explicit 'undefined' syntax
				this._styles[k] = value
			else
				delete this._styles[k]
		}
		this.updateStyle()
	}
	else
		return this._styles[name]
}

exports.Element.prototype.setAttribute = function(name, value) {
	this.dom.setAttribute(name, value)
}

exports.Element.prototype.updateStyle = function() {
	var element = this.dom
	if (!element)
		return

	/** @const */
	var cssUnits = {
		'left': 'px',
		'top': 'px',
		'width': 'px',
		'height': 'px',

		'border-radius': 'px',
		'border-width': 'px',

		'margin-left': 'px',
		'margin-top': 'px',
		'margin-right': 'px',
		'margin-bottom': 'px'
	}

	var rules = []
	for(var name in this._styles) {
		var value = this._styles[name]
		var rule = []

		var prefixedName = this._context.getPrefixedName(name)
		rule.push(prefixedName !== false? prefixedName: name)
		if (Array.isArray(value))
			value = value.join(',')

		var unit = (typeof value === 'number')? cssUnits[name] || '': ''
		value += unit

		var prefixedValue = window.Modernizr.prefixedCSSValue(name, value)
		rule.push(prefixedValue !== false? prefixedValue: value)

		rules.push(rule.join(':'))
	}

	this.dom.setAttribute('style', rules.join(';'))
}

exports.Element.prototype.append = function(el) {
	this.dom.appendChild((el instanceof Node)? el: el.dom)
}

exports.Element.prototype.remove = function() {
	this.dom.remove()
}

exports.Window = function(context, dom) {
	_globals.core.EventEmitter.apply(this)
	this._context = context
	this.dom = dom

	registerGenericListener(this)
}

exports.Window.prototype = Object.create(_globals.core.EventEmitter.prototype)
exports.Window.prototype.constructor = exports.Window

exports.Window.prototype.width = function() {
	return this.dom.innerWidth
}

exports.Window.prototype.height = function() {
	return this.dom.innerHeight
}

exports.getElement = function(tag) {
	var tags = document.getElementsByTagName(tag)
	if (tags.length != 1)
		throw new Error('no tag ' + tag + '/multiple tags')
	return new exports.Element(this, tags[0])
}
