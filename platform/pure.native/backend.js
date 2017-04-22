/*** @using { core.RAIIEventEmitter } **/
/*** @using { core.Text } **/
/*** @using { core.Image } **/

exports.capabilities = {}
var runtime = _globals.pure.runtime
var renderer = null
var rootItem = null

var rgba_re = /rgba\((\d+),(\d+),(\d+),(.*)\)/

var Rect = runtime.Rect

var _paintRect = function(renderer, rect) {
	var color = this._styles['background-color']
	if (color === undefined)
		return

	var m = rgba_re.exec(color)
	if (m === null) {
		log('invalid color specification: ' + color)
		return
	}
	renderer.paintRectangle(rect, parseInt(m[1]), parseInt(m[2]), parseInt(m[3]), Math.floor(parseFloat(m[4]) * 255))
}

var _paintImage = function(renderer, rect) {
	renderer.paintImage(rect, this._image)
}


exports.init = function(ctx) {
	renderer = new runtime.Renderer(480, 640) //fixme: pass in options?
	rootItem = ctx.element = new Element(ctx, ctx.getTag())
	ctx.width = renderer.width
	ctx.height = renderer.height
}

exports.run = function(ctx) {
	ctx._run()
}

exports.createElement = function(ctx, tag) {
	return new Element(ctx, tag, _paintRect)
}

exports.initImage = function(image) {
	var element = image.element
	element._image = new Image()
	element._paint = _paintImage
}

var ImageStatusNull			= 0
var ImageStatusLoaded		= 1
var ImageStatusUnloaded		= 2
var ImageStatusError		= 3


exports.loadImage = function(image) {
	log('loading image ' + image.source)
	var Image = _globals.core.Image
	var element = image.element
	image.status = Image.Loading
	element._image.load(image.source, function(status) {
		log('image ' + image.source + ' status: ' + status + ' ' + element._image.width + ' ' + element._image.height)
		image.paintedWidth = element._image.width
		image.paintedHeight = element._image.height
		if (!image.width)
			image.width = image.paintedWidth
		if (!image.height)
			image.height = image.paintedHeight
		switch(status) {
			case ImageStatusNull:	image.status = Image.Null; break
			case ImageStatusLoaded:	image.status = Image.Ready; break
			case ImageStatusError:	image.status = Image.Error; break
		}
		element.update()
	})
}

Element.prototype.setHtml = function(html) {
	this._text.text = html
	this.layoutText()
}

Element.prototype.layoutText = function() {
	var text = this._text, ui = this.ui, font = ui.font
	if (text.font !== font)
		text.font = font

	var w = text.width, h = text.height
	ui.paintedWidth = w
	ui.paintedHeight = h
	switch(this._styles['text-align']) {
		case 'right':
			this._offsetX = ui.width - w
			break
		case 'center':
			this._offsetX = Math.floor((ui.width - w) / 2)
			break
		default:
			this._offsetX = 0
			break
	}
	// for(var name in this._styles)
	// 	log('text style', name, this._styles[name])
	this.update()
}

var _paintText = function(renderer, rect) {
	renderer.paintText(rect.moved(this._offsetX, this._offsetY), this._text)
}

exports.initText = function(text) {
	var element = text.element
	element._offsetX = 0
	element._offsetY = 0
	element.ui = text
	element._text = new Text()
	element._text.text = text.text
	element._paint = _paintText
	element.update()
}

exports.layoutText = function(text) {
	text.element.layoutText()
}

exports.requestAnimationFrame = function(callback) {
	return setTimeout(callback, 0)
}

exports.cancelAnimationFrame = function (timer) {
	clearTimeout(timer)
}
