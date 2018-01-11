/*** @using { core.RAIIEventEmitter } **/

const layout = require('ui/layouts/absolute-layout')
const AbsoluteLayout = layout.AbsoluteLayout

class Element extends _globals.core.RAIIEventEmitter {
	constructor(ctx, impl) {
		super(ctx)
		this.ctx = ctx
		this.impl = impl
	}

	append(el) {
		this.impl.addChild((el instanceof Element)? el.impl: el)
	}

	remove() {
		let impl = this.impl
		let parent = impl.parent
		if (parent)
			parent.removeChild(impl)
	}

	addClass(name) {
		log('Element.addClass', name)
	}

	style(name, value) {
		log('Element.style', name, value)
	}
}

exports.capabilities = {}
exports.init = function(ctx) {
	log('backend initialization...')
	const options = ctx.options
	const parentLayout = options.nativeContext.getViewById(options.id)
	if (!parentLayout)
		throw new Error('could not find view with id ' + options.id)
	ctx.element = new Element(ctx, parentLayout)
}

exports.run = function(ctx, callback) {
	callback()
}

exports.initSystem = function(system) {
}

exports.createElement = function(ctx, tag) {
	log('creating element', tag)
	return new Element(ctx, new AbsoluteLayout())
}

exports.initImage = function(image) {
}

var ImageStatusNull			= 0
var ImageStatusLoaded		= 1
var ImageStatusUnloaded		= 2
var ImageStatusError		= 3


exports.loadImage = function(image) {
	log('loading image ' + image.source)
}

exports.initText = function(text) {
}

exports.setText = function(text, html) {
	log('setText')
}

exports.layoutText = function(text) {
	log('layoutText')
}

exports.setAnimation = function (component, name, animation) {
	return false
}

exports.requestAnimationFrame = function(callback) {
	return setTimeout(callback, 0)
}

exports.cancelAnimationFrame = function (timer) {
	clearTimeout(timer)
}

exports.tick = function(ctx) {
}
