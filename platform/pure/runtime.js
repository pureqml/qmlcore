var Rect = function(l, t, r, b) {
	this.l = l || 0
	this.t = t || 0
	this.r = r || 0
	this.b = b || 0
}

Rect.prototype.constructor = Rect
Rect.prototype.toString = function() {
	return '[' + this.l + ', ' + this.t + ', ' + this.r + ', ' + this.b + ']'
}

Rect.prototype.valid = function() {
	return this.b > this.t && this.r > this.l
}

Rect.prototype.union = function(rect) {
	return new Rect(
		Math.min(this.l, rect.l),
		Math.min(this.t, rect.t),
		Math.max(this.r, rect.r),
		Math.max(this.b, rect.b)
	)
}

Rect.prototype.interspect = function(rect) {
	return new Rect(
		Math.max(this.l, rect.l),
		Math.max(this.t, rect.t),
		Math.min(this.r, rect.r),
		Math.min(this.b, rect.b)
	)
}

exports.rootItem = null

var PureItem = function() { }

var PureRect = function(data) { }
PureRect.prototype = Object.create(PureItem.prototype)
PureRect.prototype.constructor = PureRect

var PureText = function(data) {
	PureItem.call(this)
	this.layout(data)
}

PureText.prototype = Object.create(PureItem.prototype)
PureText.prototype.constructor = PureText
PureText.prototype.layout = function(data) {
	log('laying out "' + data.text + '"')
}

var PureImage = function(src) {
	PureItem.call(this)
	this.load(src)
}

PureImage.prototype = Object.create(PureItem.prototype)
PureImage.prototype.constructor = PureImage
PureImage.prototype.load = function(src) {
	log('loading image from ' + src)
}

exports.PureText = PureText
exports.PureImage = PureImage
