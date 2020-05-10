/*** @using { core.RAIIEventEmitter } **/
/*** @using { core.Text } **/
/*** @using { core.Image } **/

var blessed = require('neo-blessed')

exports.capabilities = {}

var Element = function(ctx, tag, cls) {
	this._context = ctx
	this._styleCache = {}
	var impl = null
	switch(tag) {
		case 'input':
			impl = blessed.textbox()
			break
		case 'button':
			impl = blessed.button()
			break
		default:
			log('unknown tag', tag, 'falling back to div')
		case 'div':
			switch(cls) {
				case 'core-text':
					impl = blessed.text()
				default:
					impl = blessed.box()
					break
			}
			break
	}
	if (!impl)
		throw new Error("invalid blessed object returned")
	this.impl = impl
}

var ElementPrototype = Element.prototype
ElementPrototype.append = function(child) {
	this.impl.append(child.impl)
}

ElementPrototype.remove = function() {
	this.impl.parent.remove(this.impl)
}

ElementPrototype.style = function(name, value) {
	this._context._updated.add(this)
	if (typeof name === 'object') {
		for(var k in name) {
			this._styleCache[k] = name[k]
		}
	} else {
		this._styleCache[name] = value
	}
}

ElementPrototype._style = function(name, value) {
	switch(name) {
		case 'visibility':
			this.impl.invisible = value === 'hidden'
			break;
		case 'width':
			this.impl.width = value
			break;
		case 'height':
			this.impl.height = value
		case 'width':
			break;
		case 'left':
			this.impl.left = value
			break
		case 'top':
			this.impl.top = value
			break
		case 'opacity':
			if (value < 0.75)
				this.impl.transparent = true
			break
		default:
			log("ignoring style", name, value)
	}
}

ElementPrototype.updateStyle = function() {
	var styles = this._styleCache
	this._styleCache = {}
	for(var k in styles) {
		this._style(k, styles[k])
	}
}

ElementPrototype.on = function(name, callback) {
	log('on', name)
}

ElementPrototype.focus = function() { this.impl.focus() }
ElementPrototype.blur = function() { if ('blur' in this.impl) this.impl.blur() }

ElementPrototype.fullWidth = function() { return this.impl.width }
ElementPrototype.fullHeight = function() { return this.impl.height }

ElementPrototype.getProperty = function(name) { return '' }
ElementPrototype.setProperty = function(name, value) { log('ignoring property', name, value) }
ElementPrototype.getAttribute = function(name) { return '' }
ElementPrototype.setAttribute = function(name, value) { log('ignoring attribute', name, value) }

exports.init = function(ctx) {
	log('backend initialization...')
	var screen = blessed.screen({
		smartCSR: true
	});

	ctx.__screen = screen

	var root = new Element(null, 'div', 'core-item')
	root._context = root
	root._updated = new Set()
	ctx.element = root

	screen.append(root.impl)
	screen.key(['C-c'], function(ch, key) {
		return process.exit(0);
	});

	ctx.width = screen.width
	ctx.height = screen.height
}

exports.initSystem = function(system) { }

exports.run = function(ctx, callback) {
	callback()
}

exports.createElement = function(ctx, tag, cls) {
	return new Element(ctx.element, tag, cls)
}

exports.initImage = function(image) {
}

exports.initRectangle = function(rect) {
}

var ImageStatusNull			= 0
var ImageStatusLoaded		= 1
var ImageStatusUnloaded		= 2
var ImageStatusError		= 3


exports.loadImage = function(image, callback) {
	log('loading image ' + image.source)
}

Element.prototype.setHtml = function(html) {
	this.impl.setContent(html) //html, ha :D
}

exports.initText = function(text) {
}

exports.layoutText = function(text) {
	var impl = text.element.impl

	text.paintedWidth = impl.strWidth(text.text)
	text.paintedHeight = 1
	log('layout text', text.text, text.paintedWidth, text.paintedHeight)
}

exports.setText = function(text, html) {
	text.element.impl.setContent(html)
}

exports.setAnimation = function () {
	return false
}

exports.requestAnimationFrame = function(callback) {
	return setTimeout(callback, 0)
}

exports.cancelAnimationFrame = function (timer) {
	clearTimeout(timer)
}

exports.tick = function(ctx) {
	var updated = ctx.element._updated
	updated.forEach(function(el) { el.updateStyle() })
	updated.clear()
	ctx.__screen.render()
}

var Location = function() { }

exports.createLocation = function(ui) { return new Location }

exports.fingeprint = function(fp) { }

exports.createDevice = function(ui) {
	console.log('createDevice: stub')
}

var LocalStorage = function() {}

exports.createLocalStorage = function() {
	return new LocalStorage
}

var Player = function() { }

exports.probeUrl = function(url) {
	console.log('video: probing url: ' + url)
	return 1
}

exports.createPlayer = function() {
	console.log('video: create player')
	return new Player()
}
