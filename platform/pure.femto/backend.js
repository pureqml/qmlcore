exports.capabilities = {}
exports._deviceInfo = {}

_globals.closeApp = function() {
	log("closeApp")
	fd.closeApp()
}

exports.init = function(ctx) {
	log('backend initialization...')
	var options = ctx.options
	var nativeContext = options.nativeContext

	var oldOn = fd.Object.prototype.on
	fd.Element.prototype.on = function(name, callback) {
		oldOn.call(this, name, ctx.wrapNativeCallback(callback))
	}

	ctx._attachElement(nativeContext)
	ctx.width = nativeContext.width
	ctx.height = nativeContext.height
	nativeContext.on('resize', function(w, h) {
		log("resizing context to " + w + 'x' + h)
		ctx.system.resolutionWidth = w
		ctx.system.resolutionHeight = h
		ctx.width = w
		ctx.height = h
	})
	nativeContext.on('keydown', ctx.wrapNativeCallback(function(key) {
		var event = {
			timestamp: new Date().getTime()
		}
		return ctx.processKey(key, event)
	}))
	log('window size', ctx.width, ctx.height)
	exports._deviceInfo = fd.getDeviceInfo()
}


exports.run = function(ctx, callback) {
	ctx.system.device = exports._deviceInfo.device
	//schedule onload event
	callback()
}

exports.initSystem = function(system) {
}

exports.createElement = function(ctx, tag, cls) {
	switch(tag) {
		case 'input':
			return new fd.Input()
		case 'spinner':
			return new fd.Spinner()
		default:
			return new fd.Element()
	}
}

exports.initRectangle = function(rect) {
	rect._attachElement(new fd.Rectangle())
}

exports.initImage = function(image) {
	image._attachElement(new fd.Image())
}

var ImageStatusNull			= 0
var ImageStatusLoaded		= 1
var ImageStatusUnloaded		= 2
var ImageStatusError		= 3


exports.loadImage = function(image, callback) {
	image.status = ImageStatusNull
	image.element.load(image.source, callback)
}

exports.initText = function(text) {
	text._attachElement(new fd.Text())
}

exports.setText = function(text, html) {
	text.element.setText(html)
}

exports.layoutText = function(text) {
	text.element.layoutText(function(metrics) {
		if (metrics !== null) {
			text.paintedWidth = metrics.width
			text.paintedHeight = metrics.height
		} else
			console.log('failed to layout text', text.text)
	})
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

exports.tick = function(ctx) { }

exports.ajax = function(ui, request) {
	var error = request.error, done = request.done
	var ctx = ui._context
	if (error)
		request.error = ctx.wrapNativeCallback(function(event) { ui.loading = false; log("Error", event); error(event); })
	if (done)
		request.done = ctx.wrapNativeCallback(function(event) { ui.loading = false; done(event); })

	ui.loading = true
	return fd.httpRequest(request)
}
