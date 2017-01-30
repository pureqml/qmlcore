/*** @used { core.RAIIEventEmitter } **/

exports.capabilities = {}
var runtime = _globals.pure.runtime
var renderer = null
var rootItem = null
var updatedItems = new Set()
var updateTimer

var rgba_re = /rgba\((\d+),(\d+),(\d+),(.*)\)/

var Rect = runtime.Rect

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


var _paintRect = function(renderer) {
	var color = this._styles['background-color']
	if (color === undefined)
		return

	var m = rgba_re.exec(color)
	if (m === null) {
		log('invalid color specification: ' + color)
		return
	}
	renderer.paintRectangle(this.getRect(), parseInt(m[1]), parseInt(m[2]), parseInt(m[3]), Math.floor(parseFloat(m[4]) * 255))
}

var _paintImage = function(renderer) {
	renderer.paintImage(this.getRect())
}

var _paintText = function(renderer) {
	renderer.paintText(this.getRect())
}

var Element = function(context, tag) {
	_globals.core.RAIIEventEmitter.apply(this)
	this._context = context
	this._styles = {}
	this._paint = _paintRect
	this.children = []
	registerGenericListener(this)
}

Element.prototype = Object.create(_globals.core.RAIIEventEmitter.prototype)
Element.prototype.constructor = Element

Element.prototype.addClass = function(cls) { }
Element.prototype.setHtml = function(cls) { }

var importantStyles = new Set([
	'left', 'top', 'width', 'height', 'visibility',
	'background-color', 'border-radius',
	'color', 'font-size', 'text-align'
])

Element.prototype._onUpdate = function(name) {
	if (importantStyles.has(name))
		this.update()
//	else
//		log('unhandled style ' + name)
}

Element.prototype.style = function(name, style) {
	if (style !== undefined) {
		this._onUpdate(name)
		if (style !== '') //fixme: replace it with explicit 'undefined' syntax
			this._styles[name] = style
		else
			delete this._styles[name]
	} else if (name instanceof Object) { //style({ }) assignment
		for(var k in name) {
			this._onUpdate(k)
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

Element.prototype.update = function() {
	updatedItems.add(this)
	if (updateTimer === undefined) {
		updateTimer = setTimeout(function() {
			log('frame paint')
			updateTimer = undefined
			updatedItems = new Set()
			rootItem.paint(renderer)
		}, 0)
	}
}

Element.prototype.append = function(child) {
	if (child._parent !== undefined)
		throw new Error('double append on element')
	child._parent = this
	this.children.push(child)
	child.update()
}

Element.prototype.remove = function() {
	var parent = this._parent
	if (parent !== undefined) {
		var idx = parent.children.indexOf(this)
		if (idx < 0)
			throw new Error('remove(): no child in parent children array')
		parent.children.splice(idx, 1)
		parent.update()
		this._parent = undefined
	} else
		throw new Error('remove() called without adding to parent')
}

Element.prototype.getRect = function() {
	var style = this._styles
	var l = style['left'] || 0, t = style['top'] || 0
	var w = style['width'] || 0, h = style['height'] || 0
	return new Rect(l, t, w + l, h + t)
}

Element.prototype.paint = function(renderer) {
	var old = renderer.rect
	renderer.rect = this.getRect()
	renderer.rect.l += old.l
	renderer.rect.t += old.t
	this._paint(renderer)
	this.children.forEach(function(child) {
		child.paint(renderer)
	})
}

exports.init = function(ctx) {
	renderer = new runtime.Renderer(480, 640) //fixme: pass in options?
	rootItem = ctx.element = new Element(ctx, ctx.getTag())
}

exports.run = function(ctx) {
	ctx._run()
}

exports.createElement = function(ctx, tag) {
	return new Element(ctx, tag)
}

exports.initImage = function(image) {
	this._image = new Image()
	image.element._paint = _paintImage
}

exports.loadImage = function(image) {
	log('loading image ' + image.source)
	this._image.load(image.source)
	image.element.update()
}

exports.initText = function(text) {
	text.element._paint = _paintText
}

exports.layoutText = function(text) {
	text.element.update()
}

exports.requestAnimationFrame = function(callback) {
	return setTimeout(callback, 0)
}

exports.cancelAnimationFrame = function (timer) {
	clearTimeout(timer)
}
