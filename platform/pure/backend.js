exports.capabilities = {}

var Element = function(context, tag) {
	this._context = context
}

Element.prototype.constructor = Element

var Backend = function() {

}

Backend.prototype.constructor = Backend

exports.Backend = Backend
//exports.Element = Element

exports.createElement = function(tag) {
	return new Element(tag)
}
