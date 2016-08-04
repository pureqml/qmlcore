//samsung guts
var widgetAPI
var tvKey
var pluginAPI

var Modernizr = window.Modernizr

exports.core.os = navigator.platform
exports.core.device = 0
exports.core.vendor = ""

exports.trace = { key: false, focus: false }

var copyArguments = function(args, src, prefix) {
	var dst = 0
	if (src === undefined)
		src = 0

	var argsLength = args.length
	var n = src < argsLength? argsLength - src: 0

	var copy
	if (prefix !== undefined) {
		copy = new Array(n + 1)
		copy[dst++] = prefix
	} else
		copy = new Array(n)

	while(n--)
		copy[dst++] = args[src++]

	return copy
}

exports.core.copyArguments = copyArguments

if ('Common' in window) {
	alert("[QML] samsung smart tv")
	exports.core.vendor = "samsung"
	exports.core.device = 1
	exports.core.os = "smartTV"

	log = function(dummy) {
		var args = copyArguments(arguments)
		alert("[QML] " + args.join(" "))
	}

	log("loading")
	widgetAPI = new window.Common.API.Widget() // Creates Common module
	log("widget ok")
	tvKey = new window.Common.API.TVKeyValue()
	log("tv ok")
	widgetAPI.sendReadyEvent() // Sends 'ready' message to the Application Manager
	log("registering keys")

	window.onShow = function() {
		var NNaviPlugin = document.getElementById("pluginObjectNNavi");
		pluginAPI = new window.Common.API.Plugin()
		pluginAPI.registFullWidgetKey()
		pluginAPI.SetBannerState(1);
		NNaviPlugin.SetBannerState(2);
		pluginAPI.unregistKey(tvKey.KEY_VOL_UP);
		pluginAPI.unregistKey(tvKey.KEY_VOL_DOWN);
		pluginAPI.unregistKey(tvKey.KEY_MUTE);
		log("plugin ok, sending ready")
	}

	log("loaded")
}

if ('VK_UNSUPPORTED' in window) {
	log = function(dummy) {
		var args = copyArguments(arguments)
		console.log("[QML] " + args.join(" "))
	}
	log("operatv deteceted")
	exports.core.vendor = "operatv"
	exports.core.device = 1
	exports.core.os = "operaOS"

	log("loaded")
}

if ('webOS' in window) {
	log = function(dummy) {
		var args = copyArguments(arguments)
		console.log("[QML] " + args.join(" "))
	}

	log("WebOS deteceted")
	exports.core.vendor = "LG"
	exports.core.device = 1
	exports.core.os = "webOS"
	log("loaded")
}

if ('tizen' in window) {
	log = function(dummy) {
		var args = copyArguments(arguments)
		console.log("[QML] " + args.join(" "))
	}

	log("[QML] Tizen")
	exports.core.vendor = "samsung"
	exports.core.device = 1
	exports.core.os = "tizen"
	log("loaded")
}

var _checkDevice = function(target, info) {
	if (navigator.userAgent.indexOf(target) < 0)
		return

	log = function(dummy) {
		var args = copyArguments(arguments)
		console.log("[QML] " + args.join(" "))
	}

	log("[QML] " + target)
	exports.core.vendor = info.vendor
	exports.core.device = info.device
	exports.core.os = info.os
	log("loaded")
}

_checkDevice('Blackberry', { 'vendor': 'blackberry', 'device': 2, 'os': 'blackberry' })
_checkDevice('Android', { 'vendor': 'google', 'device': 2, 'os': 'android' })
_checkDevice('iPhone', { 'vendor': 'apple', 'device': 2, 'os': 'iOS' })
_checkDevice('iPad', { 'vendor': 'apple', 'device': 2, 'os': 'iOS' })
_checkDevice('iPod', { 'vendor': 'apple', 'device': 2, 'os': 'iOS' })

if (exports.core.os == "smartTV")
{
	exports.core.keyCodes = {
		4: 'Left',
		5: 'Right',
		17: '0',
		101: '1',
		98: '2',
		6: '3',
		8: '4',
		9: '5',
		10: '6',
		12: '7',
		13: '8',
		14: '9',
		20: 'Green',
		21: 'Yellow',
		22: 'Blue',
		68: 'PageUp',
		65: 'PageDown',
		88: 'Back',
		108: 'Red',
		262: 'Menu',
		29461: 'Down',
		29460: 'Up',
		29443: 'Select'
	}
} else if (exports.core.os == "tizen") {
	exports.core.keyCodes = {
		37: 'Left',
		38: 'Up',
		39: 'Right',
		40: 'Down',
		13: 'Select',
		403: 'Red',
		404: 'Green',
		405: 'Yellow',
		406: 'Blue',
		427: 'ChannelUp',
		428: 'ChannelDown',
		457: 'Menu',
		10009: 'Back'
	}
} else if (exports.core.os == "webOS") {
	exports.core.keyCodes = {
		37: 'Left',
		38: 'Up',
		39: 'Right',
		40: 'Down',
		13: 'Select',
		33: 'ChannelUp',
		34: 'ChannelDown',
		27: 'Back',
		19: 'Pause',
		48: '0',
		49: '1',
		50: '2',
		51: '3',
		52: '4',
		53: '5',
		54: '6',
		55: '7',
		56: '8',
		57: '9',
		461: 'Back',
		403: 'Red',
		404: 'Green',
		405: 'Yellow',
		406: 'Blue',
		457: 'Menu',
		412: 'Rewind',
		417: 'FastForward',
		457: 'Info',
		413: 'Stop',
		415: 'Play'
	}
} else if (exports.core.os == "operaOS") {
	exports.core.keyCodes = {
		8: 'Back',
		13: 'Select',
		27: 'Back',
		37: 'Left',
		33: 'PageUp',
		34: 'PageDown',
		38: 'Up',
		39: 'Right',
		40: 'Down',
		403: 'Red',
		404: 'Green',
		405: 'Yellow',
		406: 'Blue',
		412: 'Rewind',
		413: 'Stop',
		415: 'Play',
		417: 'FastForward'
	}
} else {
	exports.core.keyCodes = {
		13: 'Select',
		27: 'Back',
		37: 'Left',
		32: 'Space',
		33: 'PageUp',
		34: 'PageDown',
		38: 'Up',
		39: 'Right',
		40: 'Down',
		48: '0',
		49: '1',
		50: '2',
		51: '3',
		52: '4',
		53: '5',
		54: '6',
		55: '7',
		56: '8',
		57: '9',
		112: 'Red',
		113: 'Green',
		114: 'Yellow',
		115: 'Blue',
		// Gamepad special buttons.
		6661: 'L1',
		6662: 'L2',
		6663: 'R1',
		6664: 'R2',
		6665: 'Start'
	}
}

var colorTable = {
	'maroon':	'800000',
	'red':		'ff0000',
	'orange':	'ffA500',
	'yellow':	'ffff00',
	'olive':	'808000',
	'purple':	'800080',
	'fuchsia':	'ff00ff',
	'white':	'ffffff',
	'lime':		'00ff00',
	'green':	'008000',
	'navy':		'000080',
	'blue':		'0000ff',
	'aqua':		'00ffff',
	'teal':		'008080',
	'black':	'000000',
	'silver':	'c0c0c0',
	'gray':		'080808',
	'transparent': '0000'
}

var safeCallImpl = function(callback, args, onError) {
	try { return callback.apply(null, args) } catch(ex) { onError(ex) }
}

exports.core.safeCall = function(args, onError) {
	return function(callback) { return safeCallImpl(callback, args, onError) }
}


/**
 * @constructor
 */

exports.core.Object = function(parent) {
	this.parent = parent;
	this.children = []
	this._local = {}
	this._changedHandlers = {}
	this._signalHandlers = {}
	this._pressedHandlers = {}
	this._animations = {}
	this._updaters = {}
}

exports.core.Object.prototype.constructor = exports.core.Object

exports.core.Object.prototype.addChild = function(child) {
	this.children.push(child);
}

exports.core.Object.prototype._setId = function (name) {
	var p = this;
	while(p) {
		p._local[name] = this;
		p = p.parent;
	}
}

exports.core.Object.prototype.onChanged = function (name, callback) {
	if (name in this._changedHandlers)
		this._changedHandlers[name].push(callback);
	else
		this._changedHandlers[name] = [callback];
}

exports.core.Object.prototype.removeOnChanged = function (name, callback) {
	if (name in this._changedHandlers) {
		var handlers = this._changedHandlers[name];
		for(var i = 0; i < handlers.length; ) {
			if (handlers[i] === callback) {
				handlers.splice(i, 1)
			} else
				++i
		}
	}
}

exports.core.Object.prototype._removeUpdater = function (name, callback) {
	if (name in this._updaters)
		this._updaters[name]();

	if (callback) {
		this._updaters[name] = callback;
	} else
		delete this._updaters[name]
}

exports.core.Object.prototype.onPressed = function (name, callback) {
	var wrapper
	if (name != 'Key')
		wrapper = function(key, event) { event.accepted = true; callback(key, event); return event.accepted }
	else
		wrapper = callback;

	if (name in this._pressedHandlers)
		this._pressedHandlers[name].push(wrapper);
	else
		this._pressedHandlers[name] = [wrapper];
}

exports.core.Object.prototype._update = function(name, value) {
	if (name in this._changedHandlers) {
		var handlers = this._changedHandlers[name]
		var invoker = exports.core.safeCall([value], function(ex) { log("on " + name + " changed callback failed: ", ex, ex.stack) })
		handlers.forEach(invoker)
	}
}

exports.core.Object.prototype.on = function (name, callback) {
	if (name in this._signalHandlers)
		this._signalHandlers[name].push(callback);
	else
		this._signalHandlers[name] = [callback];
}

exports.core.Object.prototype._emitSignal = function(name) {
	var args = copyArguments(arguments, 1)
	var invoker = exports.core.safeCall(args, function(ex) { log("signal " + name + " handler failed:", ex, ex.stack) })
	if (name in this._signalHandlers) {
		var handlers = this._signalHandlers[name]
		handlers.forEach(invoker)
	}
}

exports.core.Object.prototype._get = function (name) {
	var object = this;
	while(object) {
		if (name in object._local)
			return object._local[name];
		object = object.parent;
	}
	if (name in this)
		return this[name];

	throw new Error("invalid property requested: '" + name);
}

exports.core.Object.prototype.getContext = function () {
	return this._get('context')
}

exports.core.Object.prototype.setAnimation = function (name, animation) {
	this._animations[name] = animation;
}

exports.core.Object.prototype.getAnimation = function (name, animation) {
	var a = this._animations[name]
	return (a && a.enabled())? a: null;
}

exports.core.Object.prototype._tryFocus = function() { return false }

/** @constructor */
exports.core.Color = function(value) {
	if (typeof value !== 'string')
	{
		this.r = 255
		this.g = 0
		this.b = 255
		log("invalid color specification: " + value)
		return
	}
	var triplet
	if (value.substring(0, 4) == "rgba") {
		var b = value.indexOf('('), e = value.lastIndexOf(')')
		value = value.substring(b + 1, e).split(',')
		this.r = parseInt(value[0], 10)
		this.g = parseInt(value[1], 10)
		this.b = parseInt(value[2], 10)
		this.a = parseInt(value[3], 10)
		return
	}
	else {
		var h = value.charAt(0);
		if (h != '#')
			triplet = colorTable[value];
		else
			triplet = value.substring(1)
	}
	if (!triplet) {
		this.r = 255
		this.g = 0
		this.b = 255
		log("invalid color specification: " + value)
		return
	}

	var len = triplet.length;
	if (len == 3 || len == 4) {
		var r = parseInt(triplet.charAt(0), 16)
		var g = parseInt(triplet.charAt(1), 16)
		var b = parseInt(triplet.charAt(2), 16)
		var a = (len == 4)? parseInt(triplet.charAt(3), 16): 15
		this.r = (r << 4) | r;
		this.g = (g << 4) | g;
		this.b = (b << 4) | b;
		this.a = (a << 4) | a;
	} else if (len == 6 || len == 8) {
		this.r = parseInt(triplet.substring(0, 2), 16)
		this.g = parseInt(triplet.substring(2, 4), 16)
		this.b = parseInt(triplet.substring(4, 6), 16)
		this.a = (len == 8)? parseInt(triplet.substring(6, 8), 16): 255
	} else
		throw new Error("invalid color specification: " + value)
}
exports.core.Color.prototype.constructor = exports.core.Color
/** @const */
var Color = exports.core.Color

exports.core.normalizeColor = function(spec) {
	return (new Color(spec)).get()
}

/** @constructor */
exports.core.DelayedAction = function(action) {
	this.action = function() {
		this._scheduled = false
		action()
	}.bind(this)
}

exports.core.DelayedAction.prototype.schedule = function() {
	if (!this._scheduled) {
		this._scheduled = true
		qml._context.scheduleAction(this.action)
	}
}

exports.core.Color.prototype.get = function() {
	return "rgba(" + this.r + "," + this.g + "," + this.b + "," + (this.a / 255) + ")";
}

var requestAnimationFrame = Modernizr.prefixed('requestAnimationFrame', window)	|| function(callback) { return setTimeout(callback, 0) }
var cancelAnimationFrame = Modernizr.prefixed('cancelAnimationFrame', window)	|| function(id) { return clearTimeout(id) }

exports.addProperty = function(proto, type, name, defaultValue) {
	var convert
	switch(type) {
		case 'enum':
		case 'int':		convert = function(value) { return parseInt(value, 0) }; break
		case 'bool':	convert = function(value) { return value? true: false }; break
		case 'real':	convert = function(value) { return parseFloat(value) }; break
		case 'string':	convert = function(value) { return String(value) }; break
		default:		convert = function(value) { return value }; break
	}

	if (defaultValue !== undefined) {
		defaultValue = convert(defaultValue)
	} else {
		switch(type) {
			case 'enum': //fixme: add default value here
			case 'int':		defaultValue = 0; break
			case 'bool':	defaultValue = false; break
			case 'real':	defaultValue = 0.0; break
			case 'string':	defaultValue = ""; break
			case 'array':	defaultValue = []; break
			default:
				defaultValue = (type[0].toUpperCase() == type[0])? null: undefined
		}
	}

	var storageName = '__property_' + name

	Object.defineProperty(proto, name, {
		get: function() {
			var p = this[storageName]
			return p !== undefined?
				p.interpolatedValue !== undefined? p.interpolatedValue: p.value:
				defaultValue
		},

		set: function(newValue) {
			newValue = convert(newValue)
			var p = this[storageName]
			if (p === undefined) { //no storage
				if (newValue === defaultValue) //value == defaultValue, no storage allocation
					return

				p = this[storageName] = { value : defaultValue }
			}
			var animation = this.getAnimation(name)
			if (animation && p.value !== newValue) {
				if (p.frameRequest)
					cancelAnimationFrame(p.frameRequest)

				var now = new Date()
				p.started = now.getTime() + now.getMilliseconds() / 1000.0

				var src = p.interpolatedValue !== undefined? p.interpolatedValue: p.value
				var dst = newValue

				var self = this

				var complete = function() {
					cancelAnimationFrame(p.frameRequest)
					p.frameRequest = undefined
					animation.complete = function() { }
					animation.running = false
					p.interpolatedValue = undefined
					p.started = undefined
					self._update(name, dst, src)
				}

				var duration = animation.duration

				var nextFrame = function() {
					var date = new Date()
					var now = date.getTime() + date.getMilliseconds() / 1000.0
					var t = 1.0 * (now - p.started) / duration
					if (t >= 1) {
						complete()
					} else {
						p.interpolatedValue = convert(animation.interpolate(dst, src, t))
						self._update(name, p.interpolatedValue, src)
						p.frameRequest = requestAnimationFrame(nextFrame)
					}
				}

				p.frameRequest = requestAnimationFrame(nextFrame)

				animation.running = true
				animation.complete = complete
			}
			var oldValue = p.value
			if (oldValue !== newValue) {
				p.value = newValue
				if (!animation)
					this._update(name, newValue, oldValue)
			}
		},
		enumerable: true
	})
}

exports.addAliasProperty = function(self, name, getObject, getter, setter) {
	var target = getObject();
	target.onChanged(name, function(value) { self._update(name, value); });
	Object.defineProperty(self, name, {
		get: getter,
		set: setter,
		enumerable: true
	});
}

exports.addSignal = function(self, name) {
	self[name] = (function() {
		var args = copyArguments(arguments, 0, name)
		self._emitSignal.apply(self, args)
	})
}
