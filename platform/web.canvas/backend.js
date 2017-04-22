exports.capabilities = { }

var html = null
var runtime = null
var rootItem = null
var canvas = null

var proxy = [
	'requestAnimationFrame', 'cancelAnimationFrame',
	'enterFullscreenMode', 'exitFullscreenMode', 'inFullscreenMode',
	'loadImage',
	//'initText', 'layoutText', //this should not be proxy, implement this backend methods
]

exports.initImage = function(image) {
	html.initImage(image)
	image.element.ui = image
	image.element._image = image._image
}

var Renderer = function(canvas) {
	this.canvas = canvas
}

Renderer.prototype.constructor = Renderer

Renderer.prototype.fillRect = function(rect, color) {
	if (color.a < 1)
		return

	this.canvas.fillStyle = color.rgba()
	this.canvas.fillRect(rect.l, rect.t, rect.width(), rect.height())
}

Renderer.prototype.drawImage = function(rect, image, el) {
	var ui = el.ui
	this.canvas.drawImage(image,
		0, 0, ui.sourceWidth, ui.sourceHeight,
		rect.l, rect.t, ui.width, ui.height)
}

exports.init = function(ctx) {
	console.log('init')
	html = _globals.html5.html
	runtime = _globals.pure.runtime

	proxy.forEach(function(name) {
		exports[name] = html[name]
	})

	ctx.options.tag = 'canvas'
	html.init(ctx)
	ctx.canvasElement = ctx.element
	ctx.canvas = ctx.element.dom
	ctx._updatedItems = new Set()
	ctx.element = exports.createElement(ctx, ctx.getTag())

	var resizeCanvas = function() {
		console.log('resizing canvas')
		var canvas = ctx.canvas
		canvas.setAttribute('width', ctx.width)
		canvas.setAttribute('height', ctx.height)
		ctx.renderer = new Renderer(canvas.getContext("2d"))
		runtime.renderFrame(ctx)
	}
	resizeCanvas()
	ctx.onChanged('width', resizeCanvas)
	ctx.onChanged('height', resizeCanvas)

	{
		var Element = runtime.Element
		Element.prototype.setHtml = function(html) {
			//console.log('setHtml stub')
			this.layoutText()
		}

		Element.prototype.layoutText = function() {
			//console.log('layout text stub')
		}
	}
}

exports.run = function(ctx) {
	console.log('calling redraw')
	ctx.canvasElement.style('visibility', 'visible')
	runtime.renderFrame(ctx)
}

exports.createElement = function(ctx, tag) {
	if (runtime === null)
		runtime = _globals.pure.runtime //fixme: this is called from StyleSheet too early (ctor?), fix initialisation order!
	return new runtime.Element(ctx, tag)
}

exports.initText = function(text) {
	var element = text.element
	element._offsetX = 0
	element._offsetY = 0
	element.ui = text
	element.update()
}

exports.layoutText = function(text) {
	//console.log('layoutText stub')
}
