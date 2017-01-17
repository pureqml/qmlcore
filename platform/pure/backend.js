exports.capabilities = {}

var Element = function(context, tag) {
	this._context = context
}

Element.prototype.constructor = Element
Element.prototype.append = function(child) { }

exports.init = function(ctx) {
	ctx.element = new Element(ctx, ctx.getTag())
}

exports.createElement = function(ctx, tag) {
	return new Element(ctx, tag)
}

exports.initImage = function(image) {

}

exports.loadImage = function(image) {

}
