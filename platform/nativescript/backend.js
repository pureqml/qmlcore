exports.capabilities = {}
exports.init = function(ctx) {
	log('backend initialization...')
}

exports.run = function(ctx, callback) {
	callback()
}

exports.initSystem = function(system) {
}

exports.createElement = function(ctx, tag) {
	log('creating element', tag)
	return null
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

exports.requestAnimationFrame = function(callback) {
	return setTimeout(callback, 0)
}

exports.cancelAnimationFrame = function (timer) {
	clearTimeout(timer)
}
