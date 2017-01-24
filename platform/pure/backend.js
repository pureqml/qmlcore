/*** @used { core.RAIIEventEmitter } **/

exports.capabilities = {}

var registerGenericListener = function(target) {
	var prefix = '__nativeEventHandler_'
	target.onListener('',
		function(name) {
			log('registering generic event', name)
			var pname = prefix + name
			var callback = target[pname] = function() {
				COPY_ARGS(args, 0)
				target.emitWithArgs(name, args)
			}
			//target.dom.addEventListener(name, callback)
		},
		function(name) {
			log('removing generic event', name)
			var pname = prefix + name
			//target.dom.removeEventListener(name, target[pname])
		}
	)
}


var Element = function(context, tag) {
	_globals.core.RAIIEventEmitter.apply(this)
	this._context = context
	this._styles = {}
	this.children = []
	registerGenericListener(this)
}

Element.prototype = Object.create(_globals.core.RAIIEventEmitter.prototype)
Element.prototype.constructor = exports.Element

Element.prototype.constructor = Element

Element.prototype.addClass = function(cls) { }
Element.prototype.setHtml = function(cls) { }
Element.prototype.style = function(name, style) {
	if (style !== undefined) {
		if (style !== '') //fixme: replace it with explicit 'undefined' syntax
			this._styles[name] = style
		else
			delete this._styles[name]
	} else if (name instanceof Object) { //style({ }) assignment
		for(var k in name) {
			var value = name[k]
			if (value !== '') //fixme: replace it with explicit 'undefined' syntax
				this._styles[k] = value
			else
				delete this._styles[k]
		}
	}
	else
		return this._styles[name]
}
Element.prototype.updateStyle = function() { }

Element.prototype.append = function(child) {
	if (child._parent !== undefined)
		throw new Error('double append on element')
	child._parent = this
	this.children.push(child)
}

Element.prototype.remove = function() {
	var parent = this._parent
	if (parent !== undefined) {
		var idx = parent.children.indexOf(this)
		if (idx < 0)
			throw new Error('remove(): no child in parent children array')
		parent.children.splice(idx, 1)
		this._parent = undefined
	} else
		throw new Error('remove() called without adding to parent')
}

exports.init = function(ctx) {
	ctx.element = new Element(ctx, ctx.getTag())
}

exports.run = function(ctx) {
	ctx._run()
}

exports.createElement = function(ctx, tag) {
	return new Element(ctx, tag)
}

exports.initImage = function(image) {
}

exports.loadImage = function(image) {
	log('loading image from ' + image.source)
}

exports.layoutText = function(text) {
	log('laying out text ' + text)
}

exports.requestAnimationFrame = function(callback) {
	return setTimeout(callback, 0)
}

exports.cancelAnimationFrame = function (timer) {
	clearTimeout(timer)
}
