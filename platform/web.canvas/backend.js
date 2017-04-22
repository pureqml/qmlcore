exports.capabilities = { }

var html = null
var runtime = null
var rootItem = null
var canvas = null

var proxy = [
	'requestAnimationFrame', 'cancelAnimationFrame',
	'enterFullscreenMode', 'exitFullscreenMode', 'inFullscreenMode',
	'initImage', 'loadImage',
	//'initText', 'layoutText', //this should not be proxy, implement this backend methods
]

var paintRect = function(renderer, rect) {
	console.log('paintRect: ' + rect)
}

var paintText = function(renderer, rect) {
	console.log('paintText: ' + rect)
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
	canvas = ctx.element.dom
	ctx._updatedItems = new Set()
	ctx.element = exports.createElement(ctx, ctx.getTag())
	ctx.renderer = new runtime.Renderer(ctx.width, ctx.height)
	{
		var Element = runtime.Element
		Element.prototype.setHtml = function(html) {
			console.log('setHtml stub')
			this.layoutText()
		}

		Element.prototype.layoutText = function() {
			console.log('layout text stub')
		}
	}
}

exports.run = function(ctx) {
	console.log('calling redraw')
	ctx.element.update()
}

exports.createElement = function(ctx, tag) {
	if (runtime === null)
		runtime = _globals.pure.runtime //fixme: this is called from StyleSheet too early (ctor?), fix initialisation order!
	return new runtime.Element(ctx, tag, paintRect)
}

exports.initText = function(text) {
	var element = text.element
	element._offsetX = 0
	element._offsetY = 0
	element.ui = text
	element._paint = paintText
	element.update()
}

exports.layoutText = function(text) {
	console.log('layoutText stub')
}
