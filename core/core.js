//WARNING: no log() function usage before init.js

$core.device = 0
$core.vendor = ""
$core.__videoBackends = {}

/* ${init.js} */

if (!Function.prototype.bind) {
	Function.prototype.bind = function(oThis) {
		if (typeof this !== 'function') {
			throw new TypeError('Function.prototype.bind - what is trying to be bound is not callable')
		}

		var aArgs = Array.prototype.slice.call(arguments, 1),
			fToBind = this,
			fNOP    = function() {},
			fBound  = function() {
				return fToBind.apply(this instanceof fNOP && oThis
					? this
					: oThis,
					aArgs.concat(Array.prototype.slice.call(arguments)))
			}

			fNOP.prototype = this.prototype;
			fBound.prototype = new fNOP();

			return fBound;
	}

	if (log === null) {
		//old webkits with no bind don't allow binding console.log
		log = function() {
			var line = ''
			for(var i = 0; i < arguments.length; ++i) {
				line += arguments[i] + ' '
			}
			console.log(line)
		}
	}
}

if (log === null)
	log = console.log.bind(console)

var colorTable = {
	'aliceblue':			'f0f8ff',
	'antiquewhite':			'faebd7',
	'aqua':					'00ffff',
	'aquamarine':			'7fffd4',
	'azure':				'f0ffff',
	'beige':				'f5f5dc',
	'bisque':				'ffe4c4',
	'black':				'000000',
	'blanchedalmond':		'ffebcd',
	'blue':					'0000ff',
	'blueviolet':			'8a2be2',
	'brown':				'a52a2a',
	'burlywood':			'deb887',
	'cadetblue':			'5f9ea0',
	'chartreuse':			'7fff00',
	'chocolate':			'd2691e',
	'coral':				'ff7f50',
	'cornflowerblue':		'6495ed',
	'cornsilk':				'fff8dc',
	'crimson':				'dc143c',
	'cyan':					'00ffff',
	'darkblue':				'00008b',
	'darkcyan':				'008b8b',
	'darkgoldenrod':		'b8860b',
	'darkgray':				'a9a9a9',
	'darkgreen':			'006400',
	'darkgrey':				'a9a9a9',
	'darkkhaki':			'bdb76b',
	'darkmagenta':			'8b008b',
	'darkolivegreen':		'556b2f',
	'darkorange':			'ff8c00',
	'darkorchid':			'9932cc',
	'darkred':				'8b0000',
	'darksalmon':			'e9967a',
	'darkseagreen':			'8fbc8f',
	'darkslateblue':		'483d8b',
	'darkslategray':		'2f4f4f',
	'darkslategrey':		'2f4f4f',
	'darkturquoise':		'00ced1',
	'darkviolet':			'9400d3',
	'deeppink':				'ff1493',
	'deepskyblue':			'00bfff',
	'dimgray':				'696969',
	'dimgrey':				'696969',
	'dodgerblue':			'1e90ff',
	'firebrick':			'b22222',
	'floralwhite':			'fffaf0',
	'forestgreen':			'228b22',
	'fuchsia':				'ff00ff',
	'gainsboro':			'dcdcdc',
	'ghostwhite':			'f8f8ff',
	'gold':					'ffd700',
	'goldenrod':			'daa520',
	'gray':					'808080',
	'grey':					'808080',
	'green':				'008000',
	'greenyellow':			'adff2f',
	'honeydew':				'f0fff0',
	'hotpink':				'ff69b4',
	'indianred':			'cd5c5c',
	'indigo':				'4b0082',
	'ivory':				'fffff0',
	'khaki':				'f0e68c',
	'lavender':				'e6e6fa',
	'lavenderblush':		'fff0f5',
	'lawngreen':			'7cfc00',
	'lemonchiffon':			'fffacd',
	'lightblue':			'add8e6',
	'lightcoral':			'f08080',
	'lightcyan':			'e0ffff',
	'lightgoldenrodyellow':	'fafad2',
	'lightgray':			'd3d3d3',
	'lightgreen':			'90ee90',
	'lightgrey':			'd3d3d3',
	'lightpink':			'ffb6c1',
	'lightsalmon':			'ffa07a',
	'lightseagreen':		'20b2aa',
	'lightskyblue':			'87cefa',
	'lightslategray':		'778899',
	'lightslategrey':		'778899',
	'lightsteelblue':		'b0c4de',
	'lightyellow':			'ffffe0',
	'lime':					'00ff00',
	'limegreen':			'32cd32',
	'linen':				'faf0e6',
	'magenta':				'ff00ff',
	'maroon':				'800000',
	'mediumaquamarine':		'66cdaa',
	'mediumblue':			'0000cd',
	'mediumorchid':			'ba55d3',
	'mediumpurple':			'9370db',
	'mediumseagreen':		'3cb371',
	'mediumslateblue':		'7b68ee',
	'mediumspringgreen':	'00fa9a',
	'mediumturquoise':		'48d1cc',
	'mediumvioletred':		'c71585',
	'midnightblue':			'191970',
	'mintcream':			'f5fffa',
	'mistyrose':			'ffe4e1',
	'moccasin':				'ffe4b5',
	'navajowhite':			'ffdead',
	'navy':					'000080',
	'oldlace':				'fdf5e6',
	'olive':				'808000',
	'olivedrab':			'6b8e23',
	'orange':				'ffa500',
	'orangered':			'ff4500',
	'orchid':				'da70d6',
	'palegoldenrod':		'eee8aa',
	'palegreen':			'98fb98',
	'paleturquoise':		'afeeee',
	'palevioletred':		'db7093',
	'papayawhip':			'ffefd5',
	'peachpuff':			'ffdab9',
	'peru':					'cd853f',
	'pink':					'ffc0cb',
	'plum':					'dda0dd',
	'powderblue':			'b0e0e6',
	'purple':				'800080',
	'red':					'ff0000',
	'rosybrown':			'bc8f8f',
	'royalblue':			'4169e1',
	'saddlebrown':			'8b4513',
	'salmon':				'fa8072',
	'sandybrown':			'f4a460',
	'seagreen':				'2e8b57',
	'seashell':				'fff5ee',
	'sienna':				'a0522d',
	'silver':				'c0c0c0',
	'skyblue':				'87ceeb',
	'slateblue':			'6a5acd',
	'slategray':			'708090',
	'slategrey':			'708090',
	'snow':					'fffafa',
	'springgreen':			'00ff7f',
	'steelblue':			'4682b4',
	'tan':					'd2b48c',
	'teal':					'008080',
	'thistle':				'd8bfd8',
	'tomato':				'ff6347',
	'turquoise':			'40e0d0',
	'violet':				'ee82ee',
	'wheat':				'f5deb3',
	'white':				'ffffff',
	'whitesmoke':			'f5f5f5',
	'yellow':				'ffff00',
	'yellowgreen':			'9acd32',
	'': 					'',
	'transparent': 			'0000'
}

var safeCallImpl = function(callback, self, args, onError) {
	try { return callback.apply(self, args) } catch(ex) { onError(ex) }
}

exports.core.safeCall = function(self, args, onError) {
	return function(callback) { return safeCallImpl(callback, self, args, onError) }
}

/// assign compound properties starting from given target object, e.g. assign(context, 'system.os', value)
exports.core.assign = function(target, path, value) {
	var path = path.split('.')
	var n = path.length - 1
	for(var i = 0; i < n; ++i) {
		target = target[path[i]]
	}
	target[path[n]] = value
}

$core.getKeyCodeByName = function(key) {
	var codes = $core.keyCodes
	for (var i in codes) {
		if (codes[i] === key)
			return ~~i
	}
}

/* @const @type {!$core.CoreObject} */

/**
 * @constructor
 */

var CoreObjectComponent = $core.CoreObject = function(parent) {
	this._local = Object.create(parent? parent._local: null)
}

var CoreObjectComponentPrototype = CoreObjectComponent.prototype
CoreObjectComponentPrototype.componentName = 'core.CoreObject'
CoreObjectComponentPrototype.constructor = CoreObjectComponent

/** @private **/
CoreObjectComponentPrototype.$c = function() { }

/** @private **/
CoreObjectComponentPrototype.$s = function() { }

CoreObjectComponentPrototype.__init = function() {
	var c = {}
	this.$c(c)
	this.$s(c)
	this.completed()
}

/** @private **/
CoreObjectComponentPrototype.__complete = function() { /*do not add anything here, it must be empty (empty onCompleted optimisation)*/ }

///@private gets object by id
CoreObjectComponentPrototype._get = function(name, unsafe) {
	if (name in this) //do not remove in here, properties may contain undefined!
		return this[name]

	if (name in this._local)
		return this._local[name]

	if (unsafe)
		return null
	else
		throw new Error("invalid property requested: '" + name + "'")
}

/** @constructor */
var Color = $core.Color = function(value) {
	if (Array.isArray(value)) {
		this.r = value[0]
		this.g = value[1]
		this.b = value[2]
		this.a = value[3] !== undefined? value[3]: 255
		return
	}
	if (typeof value !== 'string')
	{
		this.r = this.b = this.a = 255
		this.g = 0
		log("invalid color specification: " + value, new Error().stack)
		return
	}
	var triplet
	if (value[0] === '#') {
		triplet = value.substring(1)
	} else if (value.substring(0, 4) === "rgba") {
		var b = value.indexOf('('), e = value.lastIndexOf(')')
		value = value.substring(b + 1, e).split(',')
		this.r = parseInt(value[0], 10)
		this.g = parseInt(value[1], 10)
		this.b = parseInt(value[2], 10)
		this.a = Math.floor(parseFloat(value[3]) * 255)
		return
	} else
		triplet = colorTable[value]

	if (!triplet) {
		this.r = this.b = this.a = 255
		this.g = 0
		log("invalid color specification: " + value, new Error().stack)
		return
	}

	var len = triplet.length;
	if (len === 3 || len === 4) {
		var r = parseInt(triplet[0], 16)
		var g = parseInt(triplet[1], 16)
		var b = parseInt(triplet[2], 16)
		var a = (len === 4)? parseInt(triplet[3], 16): 15
		this.r = (r << 4) | r;
		this.g = (g << 4) | g;
		this.b = (b << 4) | b;
		this.a = (a << 4) | a;
	} else if (len === 6 || len === 8) {
		this.r = parseInt(triplet.substring(0, 2), 16)
		this.g = parseInt(triplet.substring(2, 4), 16)
		this.b = parseInt(triplet.substring(4, 6), 16)
		this.a = (len === 8)? parseInt(triplet.substring(6, 8), 16): 255
	} else
		throw new Error("invalid color specification: " + value)
}

Color.interpolate = function(dst, src, t) {
	if (!(dst instanceof Color))
		dst = new Color(dst)
	if (!(src instanceof Color))
		src = new Color(src)

	var interpolate = function (dst, src, t) {
		return Math.floor(t * (dst - src) + src)
	}

	var r = interpolate(dst.r, src.r, t)
	var g = interpolate(dst.g, src.g, t)
	var b = interpolate(dst.b, src.b, t)
	var a = interpolate(dst.a, src.a, t)

	return new Color([r, g, b, a])
}

Color.normalize = function(spec) {
	if (spec instanceof Color)
		return spec
	else
		return (new Color(spec))
}

var ColorPrototype = Color.prototype
ColorPrototype.constructor = $core.Color
/** @const */

ColorPrototype.rgba = ColorPrototype.toString = function() {
	var a = this.a
	return a == 255?
		"rgb(" + this.r + "," + this.g + "," + this.b + ")":
		"rgba(" + this.r + "," + this.g + "," + this.b + "," + (a / 255) + ")";
}

var hexByte = function(v) {
	var h = (v >> 4) & 0x0f
	var l = (v) & 0x0f
	h += (h > 9)? 0x57: 0x30
	l += (l > 9)? 0x57: 0x30
	return String.fromCharCode(h, l)
}

ColorPrototype.hex = function() {
	return '#' + hexByte(this.r) + hexByte(this.g) + hexByte(this.b) + hexByte(this.a)
}

ColorPrototype.ahex = function() {
	return '#' + hexByte(this.a) + hexByte(this.r) + hexByte(this.g) + hexByte(this.b)
}

exports.addLazyProperty = function(proto, name, creator) {
	var get = function(object) {
		var properties = object.__properties
		var storage = properties[name]
		if (storage !== undefined) {
			if (storage.value === undefined) {
				storage.value = creator(object)
				var onChanged = storage.onChanged
				for(var i = 0; i < onChanged.length; ++i) {
					storage.callOnChangedWithCurrentValue(object, name, onChanged[i])
				}
			}
			return storage
		}

		return properties[name] = new PropertyStorage(creator(object))
	}

	Object.defineProperty(proto, name, {
		get: function() {
			return get(this).value
		},

		set: function(newValue) {
			var storage = get(this)
			if (storage.forwardSet(this, name, newValue, null))
				return

			throw new Error('could not set lazy property ' + name + ' in ' + proto.componentName)
		},
		enumerable: true
	})
}

exports.addConstProperty = function(proto, name, getter) {
	Object.defineProperty(proto, name, {
		get: function() {
			return getter.call(this)
		},

		set: function(newValue) {
			throw new Error('could not set const property')
		},
		enumerable: true
	})
}

var PropertyStorage = function(value) {
	this.value = value
	this.onChanged = []
}
exports.PropertyStorage = PropertyStorage

var PropertyStoragePrototype = PropertyStorage.prototype

PropertyStoragePrototype.getAnimation = function(name, animation) {
	var a = this.animation
	return (a && a.enabled() && a.duration > 0 && !a._native && a._context._completed)? a: null
}

PropertyStoragePrototype.__removeUpdater = function(callback) {
	var deps = this.deps
	for(var i = 0, n = deps.length; i < n; i += 2) {
		var object = deps[i]
		var name = deps[i + 1]
		object.removeOnChanged(name, callback)
	}
}

PropertyStoragePrototype.removeUpdater = function() {
	var oldCallback = this.callback
	if (oldCallback !== undefined) {
		this.__removeUpdater(oldCallback)
		this.deps = this.callback = undefined
	}
}

PropertyStoragePrototype.replaceUpdater = function(parent, callback, deps) {
	var oldCallback = this.callback
	if (oldCallback !== undefined)
		this.__removeUpdater(oldCallback)

	this.callback = callback
	this.deps = deps
	var connectOnChanged = parent.connectOnChanged
	for(var i = 0, n = deps.length; i < n; i += 2) {
		var object = deps[i]
		var name = deps[i + 1]
		connectOnChanged.call(parent, object, name, callback, true)
	}
	callback()
}

PropertyStoragePrototype.forwardSet = function(object, name, newValue, defaultValue) {
	var oldValue = this.getCurrentValue(defaultValue)
	if (oldValue !== null && (oldValue instanceof Object)) {
		//forward property update for mixins
		var forwardTarget = oldValue.defaultProperty
		if (forwardTarget === undefined)
			return false

		var forwardedOldValue = oldValue[forwardTarget]
		if (newValue !== forwardedOldValue) {
			oldValue[forwardTarget] = newValue
			this.callOnChanged(object, name, newValue, forwardedOldValue)
		}
		return true
	} else if (newValue instanceof Object) {
		//first assignment of mixin
		var forwardTarget = newValue.defaultProperty
		if (forwardTarget === undefined)
			return false

		object.connectOnChanged(newValue, forwardTarget, function(v, ov) {
			var storage = object.__properties[name]
			if (storage !== undefined)
				storage.callOnChanged(object, name, v, ov)
		})
		return false
	}
}

PropertyStoragePrototype.discard = function() {
	var animation = this.getAnimation()
	if (animation)
		animation.complete()
	this.onChanged = []
}

PropertyStoragePrototype.getSimpleValue = function(defaultValue) {
	var value = this.value
	return value !== undefined? value: defaultValue
}

PropertyStoragePrototype.getCurrentValue = function(defaultValue) {
	var value = this.interpolatedValue
	return value !== undefined? value: this.getSimpleValue(defaultValue)
}

PropertyStoragePrototype.setCurrentValue = function(object, name, newValue, callUpdate) {
	var oldValue = this.value
	this.interpolatedValue = undefined
	this.value = newValue
	if (callUpdate)
		this.callOnChanged(object, name, newValue, oldValue)
}

PropertyStoragePrototype.set = function(object, name, newValue, defaultValue, callUpdate) {
	var oldValue = this.value
	if (oldValue === undefined)
		oldValue = defaultValue

	if (oldValue === newValue)
		return
	if (this.forwardSet(object, name, newValue, defaultValue))
		return
	this.value = newValue
	if (callUpdate)
		this.callOnChanged(object, name, newValue, oldValue)
}

var _callOnChanged = function(object, name, value, handlers) {
	var protoCallbacks = object['__changed__' + name]
	var hasProtoCallbacks = protoCallbacks !== undefined
	var hasHandlers = handlers !== undefined

	if (!hasProtoCallbacks && !hasHandlers)
		return

	var invoker = $core.safeCall(object, [value], function(ex) { log("on " + name + " changed callback failed: ", ex, ex.stack) })

	if (hasProtoCallbacks)
		protoCallbacks.forEach(invoker)

	if (hasHandlers)
		handlers.forEach(invoker)
}

PropertyStoragePrototype.callOnChanged = function(object, name, value) {
	_callOnChanged(object, name, value, this.onChanged)
}

PropertyStoragePrototype.callOnChangedWithCurrentValue = function(object, name, callback) {
	var handlers = this.onChanged
	if (handlers.length === 0)
		return

	var value = this.value
	if (value === undefined) //default - nothing changed since storage was created.
		return

	var invoker = $core.safeCall(object, [value], function(ex) { log("on " + name + " changed callback failed: ", ex, ex.stack) })
	invoker(callback)
}

PropertyStoragePrototype.removeOnChanged = function(callback) {
	var handlers = this.onChanged
	var idx = handlers.indexOf(callback)
	if (idx >= 0)
		return handlers.splice(idx, 1)
}

var getDefaultValueForType = exports.getDefaultValueForType = function(type) {
	switch(type) {
		case 'enum': //fixme: add default value here
		case 'int':		return 0
		case 'bool':	return false
		case 'real':	return 0.0
		case 'string':	return ""
		case 'array':	return []
		case 'color':
		case 'Color':	return '#0000'
		case 'date':
		case 'Date':	return new Date()
		default:		return (type[0].toUpperCase() === type[0])? null: undefined
	}
}

var convertTo = exports.convertTo = function(type, value) {
	switch(type) {
		case 'enum':
		case 'int':		return ~~value
		case 'bool':	return value? true: false
		case 'real':	return +value
		case 'string':	return String(value)
		case 'date':
		case 'Date':	return Date(value)
		default:		return value
	}
}

var getConvertFunction = exports.getConvertFunction = function(type) {
	switch(type) {
		case 'enum':
		case 'int':		return function(value) { return ~~value }
		case 'bool':	return function(value) { return value? true: false }
		case 'real':	return function(value) { return +value }
		case 'string':	return function(value) { return String(value) }
		case 'date':
		case 'Date':	return function(value) { return new Date(value) }
		default:		return function(value) { return value }
	}
}

var isTypeAnimable = function(type) {
	switch(type) {
		case 'int':
		case 'real':
		case 'color':
		case 'Color':
			return true;
		default:
			return false;
	}
}

exports.hasProperty = function(proto, name) {
	return name in proto
}

exports.addProperty = function(proto, type, name, defaultValue) {
	var convert = getConvertFunction(type)
	var animable = isTypeAnimable(type)

	if (defaultValue !== undefined) {
		defaultValue = convert(defaultValue)
	} else {
		defaultValue = getDefaultValueForType(type)
	}

	var createStorage = function(newValue) {
		var properties = this.__properties
		var storage = properties[name]
		if (storage === undefined) { //no storage
			if (newValue === defaultValue) //value === defaultValue, no storage allocation
				return
			storage = properties[name] = new PropertyStorage(defaultValue)
		}
		return storage
	}

	var simpleGet = function() {
		var storage = this.__properties[name]
		return storage !== undefined? storage.getSimpleValue(defaultValue): defaultValue
	}

	var simpleSet = function(newValue) {
		newValue = convert(newValue)
		var storage = createStorage.call(this, newValue)
		if (storage === undefined)
			return

		storage.set(this, name, newValue, defaultValue, true)
	}

	var animatedGet = function() {
		var storage = this.__properties[name]
		return storage !== undefined?
			storage.getCurrentValue(defaultValue):
			defaultValue
	}

	var animatedSet = function(newValue) {
		newValue = convert(newValue)

		var storage = createStorage.call(this, newValue)
		if (storage === undefined)
			return

		var animation = storage.getAnimation()
		if (animation && storage.value !== newValue) {
			var context = this._context
			var backend = context.backend
			if (storage.frameRequest)
				backend.cancelAnimationFrame(storage.frameRequest)

			storage.started = Date.now()

			var src = storage.getCurrentValue(defaultValue)
			var dst = newValue

			var self = this

			var complete = function() {
				if (storage.frameRequest) {
					backend.cancelAnimationFrame(storage.frameRequest)
					storage.frameRequest = undefined
				}
				if (storage.frameRequestDelayed) {
					clearTimeout(storage.frameRequestDelayed)
					storage.frameRequestDelayed = undefined
				}
				animation.complete = function() { }
				storage.interpolatedValue = undefined
				storage.started = undefined
				animation.running = false
				storage.callOnChanged(self, name, dst, src)
			}

			var duration = animation.duration

			var nextFrame = context.wrapNativeCallback(function() {
				var now = Date.now()
				var t = 1.0 * (now - storage.started) / duration
				if (t >= 1 || !animation.active()) {
					complete()
				} else {
					storage.interpolatedValue = convert(animation.interpolate(dst, src, t))
					storage.callOnChanged(self, name, storage.getCurrentValue(defaultValue), src)
					storage.frameRequest = backend.requestAnimationFrame(nextFrame)
				}
			})

			if (animation.delay <= 0)
				storage.frameRequest = backend.requestAnimationFrame(nextFrame)
			else {
				storage.frameRequestDelayed = setTimeout(nextFrame, animation.delay)
			}

			animation.running = true
			animation.complete = complete
		}
		storage.set(this, name, newValue, defaultValue, !animation)
		// if ((!animation || !animation.running) && newValue === defaultValue)
		// 	this.__properties[name] = undefined
	}

	Object.defineProperty(proto, name, {
		get: animable? animatedGet: simpleGet,
		set: animable? animatedSet: simpleSet,
		enumerable: true
	})
}

exports.addAliasProperty = function(object, name, getObject, srcProperty) {
	var target = getObject()
	Object.defineProperty(object, name, {
		get: function() { return target[srcProperty] },
		set: function(value) { target[srcProperty] = value },
		enumerable: true
	})
	object.connectOnChanged(target, srcProperty, function(value) {
		var storage = object.__properties[name]
		if (storage !== undefined)
			storage.callOnChanged(object, name, value)
		else
			_callOnChanged(object, name, value) //call prototype handlers
	})
}

$core.createSignal = function(name) {
	return function() {
		this.emitWithArgs(name, arguments)
	}
}
$core.createSignalForwarder = function(object, name) {
	return (function() {
		object.emitWithArgs(name, arguments)
	})
}

/** @constructor */
$core.EventBinder = function(target) {
	this.target = target
	this.callbacks = {}
	this.enabled = false
}

$core.EventBinder.prototype.on = function(event, callback) {
	if (event in this.callbacks)
		throw new Error('double adding of event (' + event + ')')
	this.callbacks[event] = callback
	if (this.enabled)
		this.target.on(event, callback)
}

$core.EventBinder.prototype.constructor = $core.EventBinder

$core.EventBinder.prototype.enable = function(value) {
	if (value != this.enabled) {
		var target = this.target
		this.enabled = value
		if (value) {
			for(var event in this.callbacks)
				target.on(event, this.callbacks[event])
		} else {
			for(var event in this.callbacks)
				target.removeListener(event, this.callbacks[event])
		}
	}
}

var protoEvent = function(prefix, proto, name, callback) {
	var sname = prefix + name
	//if property was in base prototype, create shallow copy and put our handler there or we would add to base prototype's array
	var storage = proto[sname]
	if (storage !== undefined) {
		var ownStorage = proto.hasOwnProperty(sname)
		if (ownStorage)
			storage.push(callback)
		else {
			var copy = storage.slice()
			copy.push(callback)
			proto[sname] = copy
		}
	} else
		proto[sname] = [callback]
}

$core._protoOn = function(proto, name, callback)
{ protoEvent('__on__', proto, name, callback) }

$core._protoOnChanged = function(proto, name, callback)
{ protoEvent('__changed__', proto, name, callback) }

$core._protoOnKey = function(proto, name, callback)
{ protoEvent('__key__', proto, name, callback) }

$core.callMethod = function(obj, name) {
	if (!obj)
		return

	COPY_ARGS(args, 1)
	if (name in obj) {
		obj[name].apply(obj, args)
	}
}

var ObjectEnumerator = function(callback) {
	this._callback = callback
	this._queue = []
	this.history = []
}

var ObjectEnumeratorPrototype = ObjectEnumerator.prototype
ObjectEnumeratorPrototype.constructor = ObjectEnumerator

ObjectEnumeratorPrototype.unshift = function() {
	var q = this._queue
	q.unshift.apply(q, arguments)
}

ObjectEnumeratorPrototype.push = function() {
	var q = this._queue
	q.push.apply(q, arguments)
}

ObjectEnumeratorPrototype.enumerate = function(root, arg) {
	var args = [this, arg]
	var queue = this._queue
	queue.unshift(root)
	while(queue.length) {
		var el = queue.shift()
		this.history.push(el)
		var r = this._callback.apply(el, args)
		if (r)
			break
	}
}

exports.forEach = function(root, callback, arg) {
	var oe = new ObjectEnumerator(callback)
	oe.enumerate(root, arg)
	return arg
}

exports.createObject = function(item) {
	var ctx = this._context
	var completedCheckpoint = ctx.__completedCheckpoint()
	item.__init()
	var parent = item.parent
	if ('_updateVisibilityForChild' in parent)
		parent._updateVisibilityForChild(item, parent.recursiveVisible)
	if ('_tryFocus' in parent)
		parent._tryFocus()
	ctx.__processCompleted(completedCheckpoint)
}
