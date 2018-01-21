/*** @using { core.RAIIEventEmitter } **/

class Element extends _globals.core.RAIIEventEmitter {
	constructor() {
		super()
	}

	append(el) {
		//this.layout.addChild((el instanceof Element)? el.layout: el)
	}

	remove() {
		//let layout = this.layout
		//let parent = layout.parent
		//if (parent)
		//	parent.removeChild(layout)
	}

	addClass(name) {
		//log('Element.addClass', name)
	}

	_setStyle(name, value) {
	}

	style(target, value) {
		if (typeof target === 'object') {
			for(let k in target) {
				this.style(k, target[k])
			}
		} else {
			let layout = this.layout
			if (value === undefined)
				throw new Error("style is write-only")
			this._setStyle(target, value)
		}
	}
}

exports.capabilities = {}
exports.init = function(ctx) {
	log('backend initialization...')
	const options = ctx.options
	const nativeContext = options.nativeContext
	ctx.element = nativeContext
	ctx.width = nativeContext.width
	ctx.height = nativeContext.height
	log('window size', ctx.width, ctx.height)
}


exports.run = function(ctx, callback) {
	//schedule onload event
	callback()
}

exports.initSystem = function(system) {
}

exports.createElement = function(ctx, tag, cls) {
	log('creating element', tag, cls)
	return new fd.Element()
}

exports.initRectangle = function(rect) {
	rect.element = new fd.Rectangle()
}

exports.initImage = function(image) {
	image.element = new fd.Image()
}

var ImageStatusNull			= 0
var ImageStatusLoaded		= 1
var ImageStatusUnloaded		= 2
var ImageStatusError		= 3


exports.loadImage = function(image) {
	log('loading image ' + image.source)
}

exports.initText = function(text) {
	text.element = new fd.Text()
}

exports.setText = function(text, html) {
	log('setText', html)
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
