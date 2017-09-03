/*** @using { core.RAIIEventEmitter } **/
/*** @using { core.Text } **/
/*** @using { core.Image } **/

exports.capabilities = {}
var runtime = _globals.pure.runtime
var renderer = null
var rootItem = null

var Rect = runtime.Rect
var Element = runtime.Element

var Image = function(ui) {
	this.ui = ui
}

Image.prototype.load = function(source) {
	if (!source) {
		this.ui.status = this.ui.Null
		return
	}
	log('loading image', source)
	var ui = this.ui
	setTimeout(function() {
		log('image ' + source + ' loaded')
		ui.status = ui.Ready
	}, Math.random() * 1000)
}

var Text = function() { }

exports.init = function(ctx) {
	log('backend initialization...')
	ctx._updatedItems = []
	renderer = new Renderer(480, 640) //fixme: pass in options?
	ctx.renderer = renderer
	rootItem = ctx.element = new Element(ctx, ctx.getTag())
	ctx.width = renderer.width
	ctx.height = renderer.height
}

exports.run = function(ctx, callback) {
	callback()
	runtime.renderFrame(ctx)
}

exports.createElement = function(ctx, tag) {
	return new Element(ctx, tag)
}

exports.initImage = function(image) {
	var element = image.element
	element._image = new Image(image)
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

var _drawText = function(renderer, rect) {
	renderer.drawText(rect.moved(this._offsetX, this._offsetY), this._text)
}

exports.initText = function(text) {
	var element = text.element
	element._offsetX = 0
	element._offsetY = 0
	element.ui = text
	element._text = new Text()
	element._text.text = text.text
	element._paint = _drawText
	element.update()
}

exports.layoutText = function(text) {
	text.element.layoutText()
}

exports.setText = function(text, html) {
	text.element.setHtml(html)
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

var Renderer = function(w, h) {
	this.width = w
	this.height = h
	this.clip = this.getRect()
	this.rect = this.getRect()
	this.depth = 0
}

Renderer.prototype.setClip = function(clip) {
	log('setting clip to ' + clip)
}

Renderer.prototype.prefix = function() {
	var d = this.depth, r = '' + d + ':'
	while(d-- > 0)
		r += '  '
	return r
}

Renderer.prototype.getRect = function() {
	return new Rect(0, 0, this.width, this.height)
}

Renderer.prototype.fillRect = function(rect, color) {
	if (!rect.valid())
		return
	log(this.prefix() + 'paint rect ' + rect + ' with color ' + color)
}

Renderer.prototype.drawText = function(rect, text) {
	if (!rect.valid())
		return
	log(this.prefix() + 'paint text ' + rect + ' ' + text)
}

Renderer.prototype.drawImage = function(rect, image) {
	if (!rect.valid())
		return
	log(this.prefix() + 'paint image ' + rect + ' ' + image)
}
exports.Renderer = Renderer
