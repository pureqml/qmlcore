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
	this.children = []
	registerGenericListener(this)
}

Element.prototype = Object.create(_globals.core.RAIIEventEmitter.prototype)
Element.prototype.constructor = exports.Element

Element.prototype.constructor = Element
Element.prototype.append = function(child) {
	this.children.push(child)
}

Element.prototype.addClass = function(cls) { }
Element.prototype.setHtml = function(cls) { }
Element.prototype.style = function(name, value) {
	log('style', name, value)
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
