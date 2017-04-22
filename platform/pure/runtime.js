/*** @using { core.RAIIEventEmitter } **/

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

Rect.prototype.width = function() { return this.r - this.l }
Rect.prototype.height = function() { return this.b - this.t }

Rect.prototype.move = function(dx, dy) {
	this.l += dx
	this.t += dy
	this.r += dx
	this.b += dy
}

Rect.prototype.moved = function(dx, dy) {
	return new Rect(this.l + dx, this.t + dy, this.r + dx, this.b + dy)
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


var registerGenericListener = function(target) {
	var prefix = '__nativeEventHandler_'
	target.onListener('',
		function(name) {
			log('registering generic event', name)
			var pname = prefix + name
			var callback = target[pname] = function() {
				COPY_ARGS(args, 0)
				target.emitWithArgs(name, args)
			}
			//target.dom.addEventListener(name, callback)
		},
		function(name) {
			log('removing generic event', name)
			var pname = prefix + name
			//target.dom.removeEventListener(name, target[pname])
		}
	)
}

var Element = function(context, tag) {
	_globals.core.RAIIEventEmitter.apply(this)
	this._context = context
	this._styles = {}
	this.children = []
	registerGenericListener(this)
}

Element.prototype = Object.create(_globals.core.RAIIEventEmitter.prototype)
Element.prototype.constructor = Element

Element.prototype.addClass = function(cls) { }

var importantStyles = new Set([
	'left', 'top', 'width', 'height', 'visibility',
	'background-color', 'background-image',
	'border-radius',
	'color', 'font-size', 'text-align'
])

Element.prototype._onUpdate = function(name) {
	if (importantStyles.has(name))
		this.update()
//	else
//		log('unhandled style ' + name)
}

Element.prototype.style = function(name, style) {
	if (style !== undefined) {
		this._onUpdate(name)
		if (style !== '') //fixme: replace it with explicit 'undefined' syntax
			this._styles[name] = style
		else
			delete this._styles[name]
	} else if (name instanceof Object) { //style({ }) assignment
		for(var k in name) {
			this._onUpdate(k)
			var value = name[k]
			if (value !== '') //fixme: replace it with explicit 'undefined' syntax
				this._styles[k] = value
			else
				delete this._styles[k]
		}
	}
	else
		return this._styles[name]
}

Element.prototype.updateStyle = function() { }

Element.prototype.visible = function() {
	var visibility = this._styles['visibility']
	return visibility !== 'hidden'
}

var updateTimer

var renderFrame = function(ctx, renderer) {
	if (updateTimer === undefined) {
		updateTimer = setTimeout(function() {
			log('frame paint')
			updateTimer = undefined
			ctx._updatedItems.clear()
			ctx.element.paint(ctx.renderer, 0, 0)
		}, 0)
	}
}
exports.renderFrame = renderFrame

Element.prototype.update = function() {
	if (!this.visible())
		return
	var ctx = this._context
	ctx._updatedItems.add(this)

	if (!ctx.renderer || !ctx._completed)
		return

	renderFrame(ctx)
}

Element.prototype.append = function(child) {
	if (child._parent !== undefined)
		throw new Error('double append on element')
	child._parent = this
	this.children.push(child)
	child.update()
}

Element.prototype.remove = function() {
	var parent = this._parent
	if (parent !== undefined) {
		var idx = parent.children.indexOf(this)
		if (idx < 0)
			throw new Error('remove(): no child in parent children array')
		parent.children.splice(idx, 1)
		parent.update()
		this._parent = undefined
	} else
		throw new Error('remove() called without adding to parent')
}

Element.prototype.getRect = function() {
	var style = this._styles
	var l = style['left'] || 0, t = style['top'] || 0
	var w = style['width'] || 0, h = style['height'] || 0
	return new Rect(l, t, w + l, h + t)
}

Element.prototype.paint = function(renderer, x, y) {
	var visibility = this._styles['visibility']
	if (visibility === 'hidden')
		return

	var rect = this.getRect()
	rect.move(x, y)

	var color = this._styles['background-color']
	if (color !== undefined) {
		color = new _globals.core.Color(color)
		renderer.fillRect(rect, color, this)
	}

	if (this._image !== undefined) {
		renderer.drawImage(rect, this._image, this)
	}

	//render here
	this.children.forEach(function(child) {
		child.paint(renderer, rect.l, rect.t)
	})
}


exports.Rect = Rect
exports.Element = Element
