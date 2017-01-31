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


var Renderer = function(w, h) {
	this.width = w
	this.height = h
	this.clip = this.getRect()
	this.rect = this.getRect()
}

Renderer.prototype.getRect = function() {
	return new Rect(0, 0, this.width, this.height)
}

Renderer.prototype.paintRectangle = function(rect, r, g, b, a) {
	if (!rect.valid())
		return
	log('paint rect ' + rect + ' with color ' + r + ' ' + g + ' ' + b + ' ' + a)
	_renderRect(rect.l, rect.t, rect.r, rect.b, r, g, b, a)
}

Renderer.prototype.paintText = function(rect) {
	if (!rect.valid())
		return
	log('paint text ' + rect)
}

Renderer.prototype.paintImage = function(rect, image) {
	if (!rect.valid())
		return
	log('paint image ' + rect + ' ' + image)
	_renderImage(rect.l, rect.t, rect.r, rect.b, image)
}

exports.Rect = Rect
exports.Renderer = Renderer
