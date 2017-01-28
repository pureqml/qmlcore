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

Rect.prototype.clone = function() {
	return new Rect(this.l, this.t, this.r, this.b)
}

Rect.prototype.union = function(rect) {
	if (!this.valid())
		return rect.clone()
	else if (!rect.valid())
		return this.clone()
	else
		return new Rect(
			Math.min(this.l, rect.l),
			Math.min(this.t, rect.t),
			Math.max(this.r, rect.r),
			Math.max(this.b, rect.b)
	)
}

Rect.prototype.intersect = function(rect) {
	if (!this.valid())
		return rect.clone()
	else if (!rect.valid())
		return this.clone()
	else
		return new Rect(
			Math.max(this.l, rect.l),
			Math.max(this.t, rect.t),
			Math.min(this.r, rect.r),
			Math.min(this.b, rect.b)
		)
}

var PureItem = function() {
	this._dirty = new Rect()
}

PureItem.prototype.paint = function(renderer) {
	log('paint')
}

var PureRect = function(data) {
	PureItem.call(this)
}

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

var Renderer = function(w, h) {
	this.w = w
	this.h = h
	this.clip = this.getRect()
}

Renderer.prototype.getRect = function() {
	return new Rect(0, 0, this.w, this.h)
}

exports.Rect = Rect
exports.PureItem = PureItem
exports.PureRect = PureRect
exports.PureText = PureText
exports.PureImage = PureImage
exports.Renderer = Renderer
