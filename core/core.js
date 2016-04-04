//samsung guts
var widgetAPI
var tvKey
var pluginAPI

var Modernizr = window.Modernizr

exports.core.os = navigator.platform
exports.core.device = "desktop"
exports.core.vendor = ""

exports.trace = { key: false, focus: false }

if ('Common' in window) {
	alert("[QML] samsung smart tv")
	exports.core.vendor = "samsung"
	exports.core.device = "tv"
	exports.core.os = "smartTV"

	log = function(dummy) {
		var args = Array.prototype.slice.call(arguments)
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
		var args = Array.prototype.slice.call(arguments)
		console.log("[QML] " + args.join(" "))
	}
	log("operatv deteceted")
	exports.core.vendor = "operatv"
	exports.core.device = "tv"
	exports.core.os = "operaOS"

	log("loaded")
}

if ('webOS' in window) {
	log = function(dummy) {
		var args = Array.prototype.slice.call(arguments)
		console.log("[QML] " + args.join(" "))
	}

	log("WebOS deteceted")
	exports.core.vendor = "LG"
	exports.core.device = "tv"
	exports.core.os = "webOS"

	var self = this
	var history = window.history
	history.pushState({ "data": "data" }, "back pressed stub")

	window.addEventListener('popstate', function (event) {
		event.preventDefault()
		history.pushState({ "data": "data" }, "back pressed stub")
		if (!event.state)
			return
		// Emulate 'Back' pressing.
		jQuery.event.trigger({ type: 'keydown', which: 27 })
	});

	log("loaded")
}

if ('tizen' in window) {
	log = function(dummy) {
		var args = Array.prototype.slice.call(arguments)
		console.log("[QML] " + args.join(" "))
	}

	log("[QML] Tizen")
	exports.core.vendor = "samsung"
	exports.core.device = "tv"
	exports.core.os = "tizen"
	log("loaded")
}

var _checkDevice = function(target, info) {
	if (navigator.userAgent.indexOf(target) < 0)
		return

	log = function(dummy) {
		var args = Array.prototype.slice.call(arguments)
		console.log("[QML] " + args.join(" "))
	}

	log("[QML] " + target)
	exports.core.vendor = info.vendor
	exports.core.device = info.device
	exports.core.os = info.os
	log("loaded")
}

_checkDevice('Blackberry', { 'vendor': 'blackberry', 'device': 'mobile', 'os': 'blackberry' })
_checkDevice('Android', { 'vendor': 'google', 'device': 'mobile', 'os': 'android' })
_checkDevice('iPhone', { 'vendor': 'apple', 'device': 'mobile', 'os': 'iOS' })
_checkDevice('iPad', { 'vendor': 'apple', 'device': 'tablet', 'os': 'iOS' })
_checkDevice('iPod', { 'vendor': 'apple', 'device': 'player', 'os': 'iOS' })

var keyCodes
if (exports.core.os == "smartTV")
{
	keyCodes = {
		4: 'Left',
		5: 'Right',
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
	keyCodes = {
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
	keyCodes = {
		37: 'Left',
		38: 'Up',
		39: 'Right',
		40: 'Down',
		13: 'Select',
		33: 'ChannelUp',
		34: 'ChannelDown',
		27: 'Back',
		403: 'Red',
		404: 'Green',
		405: 'Yellow',
		406: 'Blue',
		457: 'Menu'
	}
} else if (exports.core.os == "operaOS") {
	keyCodes = {
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
	keyCodes = {
		13: 'Select',
		27: 'Back',
		37: 'Left',
		32: 'Space',
		33: 'PageUp',
		34: 'PageDown',
		38: 'Up',
		39: 'Right',
		40: 'Down',
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
		var handlers = this._changedHandlers[name];
		handlers.forEach(function(callback) { try { callback(value) } catch(ex) { log("on " + name + " changed callback failed: ", ex, ex.stack) }})
	}
}

exports.core.Object.prototype.on = function (name, callback) {
	if (name in this._signalHandlers)
		this._signalHandlers[name].push(callback);
	else
		this._signalHandlers[name] = [callback];
}

exports.core.Object.prototype._emitSignal = function(name) {
	var args = Array.prototype.slice.call(arguments);
	args.shift();
	if (name in this._signalHandlers) {
		var handlers = this._signalHandlers[name];
		handlers.forEach(function(callback) { try { callback.apply(this, args) } catch(ex) { log("signal " + name + " handler failed:", ex, ex.stack) } });
	}
}

exports.core.Object.prototype._get = function (name) {
	if (name in this)
		return this[name];
	var object = this;
	while(object) {
		if (name in object._local)
			return object._local[name];
		object = object.parent;
	}
	log(name, this);
	throw ("invalid property requested: '" + name + "' in context of " + this);
}

exports.core.Object.prototype.setAnimation = function (name, animation) {
	this._animations[name] = animation;
}

exports.core.Object.prototype.getAnimation = function (name, animation) {
	var a = this._animations[name]
	return (a && a.enabled())? a: null;
}

exports.core.Object.prototype._tryFocus = function() { return false }

exports._setup = function() {

	exports.core.ListModel.prototype.addChild = function(child) {
		this.append(child)
	}

	exports.core.Timer.prototype._restart = function() {
		if (this._timeout) {
			clearTimeout(this._timeout);
			this._timeout = undefined;
		}
		if (this._interval) {
			clearTimeout(this._interval);
			this._interval = undefined;
		}

		if (!this.running)
			return;

		//log("starting timer", this.interval, this.repeat);
		var self = this;
		if (this.repeat)
			this._interval = setInterval(function() { self.triggered(); }, this.interval);
		else
			this._timeout = setTimeout(function() { self.triggered(); }, this.interval);
	}

	var blend = function(dst, src, t) {
		return t * (dst - src) + src;
	}

	exports.core.Animation.prototype.interpolate = blend;
	exports.core.Animation.prototype.complete = function() { }

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
			this.r = value[0] * 1
			this.g = value[1] * 1
			this.b = value[2] * 1
			this.a = value[3] * 1
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
			throw "invalid color specification: " + value
	}
	exports.core.Color.prototype.constructor = exports.core.Color
	/** @const */
	var Color = exports.core.Color

	var normalizeColor = function(spec) {
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

	exports.core.Animation.prototype._update = function(name, value) {
		var parent = this.parent
		if (this._target && parent && parent._updateAnimation && parent._updateAnimation(this._target, this.enabled() ? this: null))
			return

		exports.core.Object.prototype._update.apply(this, arguments);
	}

	exports.core.ColorAnimation.prototype.interpolate = function(dst, src, t) {
		var dst_c = new Color(dst), src_c = new Color(src);
		var r = Math.floor(blend(dst_c.r, src_c.r, t))
		var g = Math.floor(blend(dst_c.g, src_c.g, t))
		var b = Math.floor(blend(dst_c.b, src_c.b, t))
		var a = Math.floor(blend(dst_c.a, src_c.a, t))
		return "rgba(" + r + "," + g + "," + b + "," + a + ")";
	}

	exports.core.Timer.prototype._update = function(name, value) {
		switch(name) {
			case 'running': this._restart(); break;
			case 'interval': this._restart(); break;
			case 'repeat': this._restart(); break;
		}
		exports.core.Object.prototype._update.apply(this, arguments);
	}

	var transition = {
		transition: Modernizr.prefixedCSS('transition'),
		property: Modernizr.prefixedCSS('transition-property'),
		delay: Modernizr.prefixedCSS('transition-delay'),
		duration: Modernizr.prefixedCSS('transition-duration'),
		timing: Modernizr.prefixedCSS('transition-timing-function')
	}
	log(transition)

	exports.core.Item.prototype.setTransition = function(name, animation) {
		if (transition.transition === false)
			return false

		name = Modernizr.prefixedCSS(name) || name //replace transform: <prefix>rotate hack

		var tProperty = this.element.css(transition.property).split(',')

		var idx = tProperty.indexOf(name)
		if (idx === -1) { //if property not set
			this.element.css(transition.delay, this.element.css(transition.delay) + ',0s')
			this.element.css(transition.duration, this.element.css(transition.duration) + ',' + animation.duration + 'ms')
			this.element.css(transition.property, this.element.css(transition.property) + ',' + name)
			this.element.css(transition.timing, this.element.css(transition.timing) + ',' + animation.easing)
		} else { //property already set, adjust the params
			//var tDelay = this.element.css(transition.delay).split(',') // uncomment when needed
			var tDuration = this.element.css(transition.duration).split(',')
			var tFunction = this.element.css(transition.timing).split(',') // need to handle commas between brackets

			tDuration[idx] = animation.duration + 'ms'
			tFunction[idx] = animation.easing

//			this.element.css(attr + '-delay', tDelay.toString())
			this.element.css(transition.duration, tDuration.toString())
			this.element.css(transition.duration, tFunction.toString())
		}
		return true
	}

	exports.core.Item.prototype._updateAnimation = function(name, animation) {
		if (!Modernizr.csstransitions || (animation && !animation.cssTransition))
			return false

		var css = this._mapCSSAttribute(name)

		if (css !== undefined) {
			if (!animation)
				throw "resetting transition was not implemented"

			animation._target = name
			return this.setTransition(css, animation)
		} else {
			return false
		}
	}

	exports.core.Item.prototype.setAnimation = function (name, animation) {
		if (!this._updateAnimation(name, animation))
			exports.core.Object.prototype.setAnimation.apply(this, arguments);
	}

	exports.core.Item.prototype.toScreen = function() {
		var item = this
		var x = 0, y = 0
		var w = this.width, h = this.height
		while(item) {
			x += item.x
			y += item.y
			if ('view' in item) {
				x += item.viewX + item.view.content.x
				y += item.viewY + item.view.content.y
			}
			item = item.parent
		}
		return [x, y, x + w, y + h, x + w / 2, y + h / 2];
	}

	exports.core.Border.prototype._update = function(name, value) {
		switch(name) {
			case 'width': this.parent.element.css({'border-width': value, 'margin-left': -value, 'margin-top': -value}); break;
			case 'color': this.parent.element.css('border-color', normalizeColor(value)); break;
		}
		exports.core.Object.prototype._update.apply(this, arguments);
	}

	exports.core.BorderMargin.prototype._updateStyle = function() {
		if (this.parent && this.parent.parent) {
			var el = this.parent.parent.element
			if (el) {
				var cssname = 'border-' + this.name
				if (this.margin) {
					//log(cssname, this.margin + "px solid " + new Color(this.color).get())
					el.css(cssname, this.margin + "px solid " + new Color(this.color).get())
				} else
					el.css(cssname, '')
			}
		}
	}

	exports.core.BorderMargin.prototype._update = function(name, value) {
		switch(name) {
			case 'margin': this._updateStyle(); break
			case 'color': this._updateStyle(); break
		}
		exports.core.Object.prototype._update.apply(this, arguments);
	}

	exports.core.Shadow.prototype._update = function(name, value) {
		this.parent._updateStyle()
		exports.core.Object.prototype._update.apply(this, arguments);
	}

	exports.core.Shadow.prototype._empty = function() {
		return !this.x && !this.y && !this.blur && !this.spread;
	}

	exports.core.Shadow.prototype._getFilterStyle = function() {
		var style = this.x + "px " + this.y + "px " + this.blur + "px "
		if (this.spread > 0)
			style += this.spread + "px "
		style += new Color(this.color).get()
		return style
	}

	exports.core.Effects.prototype._addStyle = function(property, style, units) {
		var value = this[property]
		if (!value)
			return ''
		return (style || property) + '(' + value + (units || '') + ') '
	}

	exports.core.Effects.prototype._getFilterStyle = function() {
		var style = []
		style.push(this._addStyle('blur', 'blur', 'px'))
		style.push(this._addStyle('grayscale'))
		style.push(this._addStyle('sepia'))
		style.push(this._addStyle('brightness'))
		style.push(this._addStyle('contrast'))
		style.push(this._addStyle('hueRotate', 'hue-rotate', 'deg'))
		style.push(this._addStyle('invert'))
		style.push(this._addStyle('saturate'))
		return style.join('')
	}

	exports.core.Effects.prototype._updateStyle = function() {
		var style = this._getFilterStyle()
		var el = this.parent.element
		if (el) {
			//chromium bug
			//https://github.com/Modernizr/Modernizr/issues/981
			el.css('-webkit-filter', style)
			el.css('filter', style)
			if (this.shadow && !this.shadow._empty())
				el.css('box-shadow', this.shadow._getFilterStyle())
		}
	}

	exports.core.Effects.prototype._update = function(name, value) {
		this._updateStyle()
		exports.core.Object.prototype._update.apply(this, arguments)
	}

	exports.core.Item.prototype.addChild = function(child) {
		exports.core.Object.prototype.addChild.apply(this, arguments)
		if (child._tryFocus())
			child._propagateFocusToParents()
	}

	exports.core.Item.prototype._mapCSSAttribute = function(name) {
		return {width: 'width', height: 'height', x: 'left', y: 'top', viewX: 'left', viewY: 'top', opacity: 'opacity', radius: 'border-radius', rotate: 'transform', boxshadow: 'box-shadow', translateX: 'transform'}[name]
	}

	exports.core.Item.prototype._update = function(name, value) {
		switch(name) {
			case 'width':
				this.element.css('width', value)
				this.boxChanged()
				break;

			case 'height':
				this.element.css('height', value);
				this.boxChanged()
				break;

			case 'x':
			case 'viewX':
				var x = this.x + this.viewX
				this.element.css('left', x);
				this.boxChanged()
				break;

			case 'y':
			case 'viewY':
				var y = this.y + this.viewY
				this.element.css('top', y);
				this.boxChanged()
				break;

			case 'opacity': if (this.element) /*FIXME*/this.element.css('opacity', value); break;
			case 'recursiveVisible': if (this.element) /*FIXME*/this.element.css('visibility', value? 'visible': 'hidden'); break;
			case 'z':		this.element.css('z-index', value); break;
			case 'radius':	this.element.css('border-radius', value); break;
			case 'translateX':	this.element.css(Modernizr.prefixedCSS('transform'), Modernizr.prefixedCSSValue('transform', 'translate3d(' + value + 'px, 0px, 0px)')); break;
			case 'clip':	this.element.css('overflow', value? 'hidden': 'visible'); break;
			case 'rotate':	this.element.css(Modernizr.prefixedCSS('transform'), Modernizr.prefixedCSSValue('transform', 'rotate(' + value + 'deg)')); break
		}
		exports.core.Object.prototype._update.apply(this, arguments);
	}

	exports.core.Item.prototype._updateVisibility = function() {
		var visible = ('visible' in this)? this.visible: true
//		var opacity = ('opacity' in this)? this.opacity: 1.0
		this.recursiveVisible = this._recursiveVisible && this.visible// && this.opacity > 0.004 //~1/255
		if (!visible && this.parent)
			this.parent._tryFocus() //try repair local focus on visibility changed
	}

	exports.core.Item.prototype.forceActiveFocus = function() {
		var item = this;
		while(item.parent) {
			item.parent._focusChild(item);
			item = item.parent;
		}
	}

	exports.core.Item.prototype._tryFocus = function() {
		if (!this.visible)
			return false

		if (this.focusedChild && this.focusedChild._tryFocus())
			return true

		var children = this.children
		for(var i = 0; i < children.length; ++i) {
			var child = children[i]
			if (child._tryFocus()) {
				this._focusChild(child)
				return true
			}
		}
		return this.focus
	}

	exports.core.Item.prototype._propagateFocusToParents = function() {
		var item = this;
		while(item.parent && (!item.parent.focusedChild || !item.parent.focusedChild.visible)) {
			item.parent._focusChild(item)
			item = item.parent
		}
	}
	exports.core.Item.prototype.hasActiveFocus = function() {
		var item = this
		while(item.parent) {
			if (item.parent.focusedChild != item)
				return false

			item = item.parent
		}
		return true
	}

	exports.core.Item.prototype._focusTree = function(active) {
		this.activeFocus = active;
		if (this.focusedChild)
			this.focusedChild._focusTree(active);
	}

	exports.core.Item.prototype._focusChild = function (child) {
		if (child.parent !== this)
			throw "invalid object passed as child"
		if (this.focusedChild === child)
			return
		if (this.focusedChild)
			this.focusedChild._focusTree(false)
		this.focusedChild = child
		if (this.focusedChild)
			this.focusedChild._focusTree(this.hasActiveFocus())
	}

	exports.core.Item.prototype.focusChild = function(child) {
		this._propagateFocusToParents()
		this._focusChild(child)
	}

	exports.core.Item.prototype._processKey = function (event) {
		this._tryFocus() //soft-restore focus for invisible components
		if (this.focusedChild && this.focusedChild.visible) {
			if (this.focusedChild._processKey(event))
				return true
		}

		var key = keyCodes[event.which];
		if (key) {
			if (key in this._pressedHandlers) {
				var handlers = this._pressedHandlers[key];
				for(var i = handlers.length - 1; i >= 0; --i) {
					var callback = handlers[i]
					try {
						if (callback(key, event)) {
							if (exports.trace.key)
								log("key", key, "handled by", this, new Error().stack)
							return true;
						}
					} catch(ex) {
						log("on " + key + " handler failed:", ex, ex.stack)
					}
				}
			}

			if ('Key' in this._pressedHandlers) {
				var handlers = this._pressedHandlers['Key'];
				for(var i = handlers.length - 1; i >= 0; --i) {
					var callback = handlers[i]
					try {
						if (callback(key, event)) {
							if (exports.trace.key)
								log("key", key, "handled by", this, new Error().stack)
							return true
						}
					} catch(ex) {
						log("onKeyPressed handler failed:", ex, ex.stack)
					}
				}
			}
		}
		else {
			log("unhandled key", event.which);
		}
		return false;
	}

	exports.core.AnchorLine.prototype.toScreen = function() {
		return this.parent.toScreen()[this.boxIndex]
	}

	/** @private */
	exports.core.Anchors.prototype._updateLeft = function() {
		var anchors = this
		var self = anchors.parent
		var parent = self.parent

		var parent_box = parent.toScreen()
		var left = anchors.left.toScreen()

		var lm = anchors.leftMargin || anchors.margins
		self.x = left + lm - parent_box[0] - self.viewX
		if (anchors.right) {
			var right = anchors.right.toScreen()
			var rm = anchors.rightMargin || anchors.margins
			self.width = right - left - rm - lm
		}
	}

	/** @private */
	exports.core.Anchors.prototype._updateRight = function() {
		var anchors = this
		var self = anchors.parent
		var parent = self.parent

		var parent_box = parent.toScreen()
		var right = anchors.right.toScreen()

		var lm = anchors.leftMargin || anchors.margins
		var rm = anchors.rightMargin || anchors.margins
		if (anchors.left) {
			var left = anchors.left.toScreen()
			self.width = right - left - rm - lm
		}
		self.x = right - parent_box[0] - rm - self.width - self.viewX
	}

	/** @private */
	exports.core.Anchors.prototype._updateTop = function() {
		var anchors = this
		var self = anchors.parent
		var parent = self.parent

		var parent_box = parent.toScreen()
		var top = anchors.top.toScreen()

		var tm = anchors.topMargin || anchors.margins
		var bm = anchors.bottomMargin || anchors.margins
		self.y = top + tm - parent_box[1] - self.viewY
		if (anchors.bottom) {
			var bottom = anchors.bottom.toScreen()
			self.height = bottom - top - bm - tm
		}
	}

	/** @private */
	exports.core.Anchors.prototype._updateBottom = function() {
		var anchors = this
		var self = anchors.parent
		var parent = self.parent

		var parent_box = parent.toScreen()
		var bottom = anchors.bottom.toScreen()

		var tm = anchors.topMargin || anchors.margins
		var bm = anchors.bottomMargin || anchors.margins
		if (anchors.top) {
			var top = anchors.top.toScreen()
			self.height = bottom - top - bm - tm
		}
		self.y = bottom - parent_box[1] - bm - self.height - self.viewY
	}

	/** @private */
	exports.core.Anchors.prototype._updateHCenter = function() {
		var anchors = this
		var self = anchors.parent
		var parent = self.parent

		var parent_box = parent.toScreen();
		var hcenter = anchors.horizontalCenter.toScreen();
		var lm = anchors.leftMargin || anchors.margins;
		var rm = anchors.rightMargin || anchors.margins;
		self.x = hcenter - self.width / 2 - parent_box[0] + lm - rm - self.viewX;
	}

	/** @private */
	exports.core.Anchors.prototype._updateVCenter = function() {
		var anchors = this
		var self = anchors.parent
		var parent = self.parent

		var parent_box = parent.toScreen();
		var vcenter = anchors.verticalCenter.toScreen();
		var tm = anchors.topMargin || anchors.margins;
		var bm = anchors.bottomMargin || anchors.margins;
		self.y = vcenter - self.height / 2 - parent_box[1] + tm - bm - self.viewY;
	}

	exports.core.Anchors.prototype._update = function(name) {
		var self = this.parent
		var anchors = this

		switch(name) {
			case 'left':
				var update_left = this._updateLeft.bind(this)
				update_left()
				anchors.left.parent.on('boxChanged', update_left)
				anchors.onChanged('leftMargin', update_left)
				break

			case 'right':
				var update_right = this._updateRight.bind(this)
				update_right()
				self.onChanged('width', update_right)
				anchors.right.parent.on('boxChanged', update_right)
				anchors.onChanged('rightMargin', update_right)
				break

			case 'top':
				var update_top = this._updateTop.bind(this)
				update_top()
				anchors.top.parent.on('boxChanged', update_top)
				anchors.onChanged('topMargin', update_top)
				break

			case 'bottom':
				var update_bottom = this._updateBottom.bind(this)
				update_bottom()
				self.onChanged('height', update_bottom)
				anchors.bottom.parent.on('boxChanged', update_bottom)
				anchors.onChanged('bottomMargin', update_bottom)
				break

			case 'horizontalCenter':
				var update_h_center = this._updateHCenter.bind(this)
				update_h_center()
				self.onChanged('width', update_h_center)
				anchors.onChanged('leftMargin', update_h_center)
				anchors.onChanged('rightMargin', update_h_center)
				anchors.horizontalCenter.parent.on('boxChanged', update_h_center)
				break

			case 'verticalCenter':
				var update_v_center = this._updateVCenter.bind(this)
				update_v_center()
				self.onChanged('height', update_v_center)
				anchors.onChanged('topMargin', update_v_center)
				anchors.onChanged('bottomMargin', update_v_center)
				anchors.verticalCenter.parent.on('boxChanged', update_v_center)
				break

			case 'fill':
				anchors.left = anchors.fill.left
				anchors.right = anchors.fill.right
				anchors.top = anchors.fill.top
				anchors.bottom = anchors.fill.bottom
				break

			case 'centerIn':
				anchors.horizontalCenter = anchors.centerIn.horizontalCenter
				anchors.verticalCenter = anchors.centerIn.verticalCenter
				break
		}
		exports.core.Object.prototype._update.apply(this, arguments)
	}

	exports.core.Font.prototype._update = function(name, value) {
		switch(name) {
			case 'family':		this.parent.element.css('font-family', value); this.parent._updateSize(); break
			case 'pointSize':	this.parent.element.css('font-size', value + "pt"); this.parent._updateSize(); break
			case 'pixelSize':	this.parent.element.css('font-size', value + "px"); this.parent._updateSize(); break
			case 'italic': 		this.parent.element.css('font-style', value? 'italic': 'normal'); this.parent._updateSize(); break
			case 'bold': 		this.parent.element.css('font-weight', value? 'bold': 'normal'); this.parent._updateSize(); break
			case 'underline':	this.parent.element.css('text-decoration', value? 'underline': ''); this.parent._updateSize(); break
			case 'shadow':		this.parent.element.css('text-shadow', value? '1px 1px black': 'none'); this.parent._updateSize(); break;
			case 'lineHeight':	this.parent.element.css('line-height', value + "px"); this.parent._updateSize(); break;
			case 'weight':	this.parent.element.css('font-weight', value); this.parent._updateSize(); break;
		}
		exports.core.Object.prototype._update.apply(this, arguments);
	}

	exports.core.Text.prototype.onChanged = function (name, callback) {
		if (!this._updateSizeNeeded) {
			if (name === "right" || name === "width" || name === "bottom" || name === "height" || name === "verticalCenter" || name === "horizontalCenter") {
				this._updateSizeNeeded = true;
				this._updateSize();
			}
		}
		exports.core.Object.prototype.onChanged.apply(this, arguments);
	}

	exports.core.Text.prototype._updateSize = function() {
		if (this._updateSizeNeeded)
			this._delayedUpdateSize.schedule()
	}

	exports.core.Text.prototype._updateSizeImpl = function() {
		if (!this._updateSizeNeeded)
			return;

		if (this.text.length === 0) {
			this.paintedWidth = 0
			this.paintedHeight = 0
			return
		}

		var element = this.element
		var wrap = this.wrapMode != exports.core.Text.NoWrap
		if (!wrap)
			element.css('width', '') //no need to reset it to width, it's already there
		element.css('height', '')

		var w = element.width();
		var h = element.height();
		if (!wrap)
			element.css('width', this.width)
		element.css('height', this.height)
		this.paintedWidth = w;
		this.paintedHeight = h;
		switch(this.verticalAlignment) {
		case this.AlignTop:		element.css('margin-top', 0); break
		case this.AlignBottom:	element.css('margin-top', this.height - this.paintedHeight); break
		case this.AlignVCenter:	element.css('margin-top', (this.height - this.paintedHeight) / 2); break
		}
	}

	var htmlRe = /[&<]/

	exports.core.Text.prototype._update = function(name, value) {
		switch(name) {
			case 'text': if (htmlRe.exec(value)) this.element.html(value); else this.element.text(value); this._updateSize(); break;
			case 'color': this.element.css('color', normalizeColor(value)); break;
			case 'width': this._updateSize(); break;
			case 'verticalAlignment': this.verticalAlignment = value; this._updateSize(); break
			case 'horizontalAlignment':
				switch(value) {
				case this.AlignLeft:	this.element.css('text-align', 'left'); break
				case this.AlignRight:	this.element.css('text-align', 'right'); break
				case this.AlignHCenter:	this.element.css('text-align', 'center'); break
				case this.AlignJustify:	this.element.css('text-align', 'justify'); break
				}
				break
			case 'wrapMode':
				switch(value) {
				case this.NoWrap:		this.element.css('white-space', 'nowrap'); break
				case this.WordWrap:		this.element.css('white-space', 'normal'); break
				case this.WrapAnywhere:	this.element.css('white-space', 'nowrap'); break	//TODO: implement.
				case this.Wrap:			this.element.css('white-space', 'nowrap'); break	//TODO: implement.
				}
				this._updateSize();
				break
		}
		exports.core.Item.prototype._update.apply(this, arguments);
	}

	exports.core.Gradient.prototype.addChild = function(child) {
		this.stops.push(child)
		this.stops.sort(function(a, b) { return a.position > b.position; })
	}

	exports.core.GradientStop.prototype._update = function() {
		this.parent.parent._update('gradient', this.parent)
	}

	exports.core.GradientStop.prototype._getDeclaration = function() {
		return normalizeColor(this.color) + " " + Math.floor(100 * this.position) + "%"
	}

	exports.core.Gradient.prototype._getDeclaration = function() {
		var decl = []
		var orientation = this.orientation == this.Vertical? 'bottom': 'left'
		decl.push(orientation)

		var stops = this.stops
		var n = stops.length
		if (n < 2)
			return

		for(var i = 0; i < n; ++i) {
			var stop = stops[i]
			decl.push(stop._getDeclaration())
		}
		return decl.join()
	}

	exports.core.Rectangle.prototype._mapCSSAttribute = function(name) {
		var attr = {color: 'background-color'}[name]
		return (attr !== undefined)?
			attr:
			exports.core.Item.prototype._mapCSSAttribute.apply(this, arguments)
	}

	exports.core.Rectangle.prototype._update = function(name, value) {
		switch(name) {
			case 'color': this.element.css('background-color', normalizeColor(value)); break;
			case 'gradient': {
				if (value) {
					var decl = value._getDeclaration()
					this.element.css('background-color', '')
					this.element.css('background', Modernizr.prefixedCSSValue('background', 'linear-gradient(to ' + decl + ')'))
				} else {
					this.element.css('background', '')
					this._update('color', normalizeColor(this.color)) //restore color
				}
				break;
			}
		}
		exports.core.Item.prototype._update.apply(this, arguments);
	}

	exports.core.Image.prototype._init = function() {
		var tmp = new Image()
		this._image = tmp
		this._image.onerror = this._onError.bind(this)

		var image = this
		this._image.onload = function() {
			image.paintedWidth = tmp.naturalWidth
			image.paintedHeight = tmp.naturalHeight

			image.element.css('background-image', 'url(' + image.source + ')')
			switch(image.fillMode) {
				case image.Stretch:
					image.element.css('background-repeat', 'no-repeat')
					image.element.css('background-size', '100% 100%')
					break;
				case image.TileVertically:
					image.element.css('background-repeat', 'repeat-y')
					image.element.css('background-size', '100%')
					break;
				case image.TileHorizontally:
					image.element.css('background-repeat', 'repeat-x')
					image.element.css('background-size', tmp.naturalWidth + 'px 100%')
					break;
				case image.PreserveAspectFit:
					image.element.css('background-repeat', 'no-repeat')
					image.element.css('background-position', 'center')
					var wPart = image.width / tmp.naturalWidth
					var hPart = image.height / tmp.naturalHeight
					var wRatio = 100
					var hRatio = 100
					if (wPart > hPart)
						wRatio = Math.floor(100 / wPart * hPart)
					else
						hRatio = Math.floor(100 / hPart * wPart)
					image.element.css('background-size', wRatio + '% ' + hRatio + '%')
					image.paintedWidth = image.width * wRatio / 100
					image.paintedHeight = image.height * hRatio / 100
					break;
				case image.PreserveAspectCrop:
					image.element.css('background-repeat', 'no-repeat')
					image.element.css('background-position', 'center')
					var pRatio = tmp.naturalWidth / tmp.naturalHeight
					var iRatio = image.width / image.height
					if (pRatio < iRatio) {
						var hRatio = Math.floor(iRatio / pRatio * 100)
						image.element.css('background-size', 100 + '% ' + hRatio + '%')
					}
					else {
						var wRatio = Math.floor(pRatio / iRatio * 100)
						image.element.css('background-size', wRatio + '% ' + 100 + '%')
					}
					break;
				case image.Tile:
					image.element.css('background-repeat', 'repeat-y repeat-x')
					break;
			}

			if (!image.width)
				image.width = image.paintedWidth
			if (!image.height)
				image.height = image.paintedHeight
			image.status = image.Ready
		}
		this.load()
	}

	exports.core.Image.prototype._onError = function() {
		this.status = this.Error;
	}

	exports.core.Image.prototype.load = function() {
		var src = this.source
		this.status = (src.length === 0)? exports.core.Image.Null: exports.core.Image.Loading
		this._image.src = src
	}

	exports.core.Image.prototype._update = function(name, value) {
		switch(name) {
			case 'width':
			case 'height':
//			case 'rotate':
			case 'fillMode': this.load(); break;
			case 'source':
				this.status = value ? this.Loading : this.Null;
				if (value)
					this.load();
				break;
		}
		exports.core.Item.prototype._update.apply(this, arguments);
	}

	exports.core.Row.prototype._layout = function() {
		var children = this.children;
		var p = 0
		var h = 0
		for(var i = 0; i < children.length; ++i) {
			var c = children[i]
			if (!('height' in c))
				continue
			var b = c.y + c.height
			if (b > h)
				h = b
			c.viewX = p
			if (c.recursiveVisible)
				p += c.width + this.spacing
		}
		if (p > 0)
			p -= this.spacing
		this.contentWidth = p
		this.contentHeight = h
	}

	exports.core.Row.prototype.addChild = function(child) {
		exports.core.Item.prototype.addChild.apply(this, arguments)
		var delayedLayout = this._delayedLayout
		child.onChanged('recursiveVisible', delayedLayout.schedule.bind(delayedLayout))
		child.onChanged('width', delayedLayout.schedule.bind(delayedLayout))
	}

	exports.core.Column.prototype._layout = function() {
		var children = this.children;
		var p = 0
		var w = 0
		for(var i = 0; i < children.length; ++i) {
			var c = children[i]
			if (!('height' in c))
				continue
			var r = c.x + c.width
			if (r > w)
				w = r
			c.viewY = p + c.anchors.topMargin
			if (c.recursiveVisible)
				p += c.height + c.anchors.topMargin + this.spacing
		}
		if (p > 0)
			p -= this.spacing
		this.contentWidth = w
		this.contentHeight = p
	}

	exports.core.Column.prototype.addChild = function(child) {
		exports.core.Item.prototype.addChild.apply(this, arguments)
		var delayedLayout = this._delayedLayout
		child.onChanged('height', delayedLayout.schedule.bind(delayedLayout))
		child.onChanged('recursiveVisible', delayedLayout.schedule.bind(delayedLayout))
	}

	exports.core.PageStack.prototype._layout = function() {
		this.count = this.children.length;
		for (var i = 0; i < this.count; ++i)
			this.children[i].visible = (i == this.currentIndex);

		var c = this.children[this.currentIndex];
		this.contentHeight = c.height;
		this.contentWidth = c.width;
	}

	exports.core.PageStack.prototype.addChild = function(child) {
		exports.core.Item.prototype.addChild.apply(this, arguments)
		var delayedLayout = this._delayedLayout
		child.onChanged('height', delayedLayout.schedule.bind(delayedLayout))
		child.onChanged('recursiveVisible', delayedLayout.schedule.bind(delayedLayout))
	}

	exports.core.Grid.prototype._layout = function() {
		var children = this.children;
		var cX = 0, cY = 0, xMax = 0, yMax = 0;
		for(var i = 0; i < children.length; ++i) {
			var c = children[i]
			if (c.recursiveVisible) {
				if (this.width - cX < c.width) {
					c.x = 0;
					c.y = yMax + c.anchors.topMargin;// + (cY === 0 ? 0 : this.spacing);
					cY = yMax;// + this.spacing;
					yMax = c.y + c.height + this.spacing;
				} else {
					c.x = cX;
					c.y = cY + c.anchors.topMargin;
				}
				if (yMax < c.y + c.height)
					yMax = c.y + c.height + this.spacing;
				if (xMax < c.x + c.width)
					xMax = c.x + c.width;
				cX = c.x + c.width + this.spacing;
			}
		}
		this.contentHeight = yMax;
		this.contentWidth = xMax;
	}

	exports.core.Grid.prototype.addChild = function(child) {
		exports.core.Item.prototype.addChild.apply(this, arguments)
		var delayedLayout = this._delayedLayout
		child.onChanged('height', delayedLayout.schedule.bind(delayedLayout))
		child.onChanged('width', delayedLayout.schedule.bind(delayedLayout))
		child.onChanged('recursiveVisible', delayedLayout.schedule.bind(delayedLayout))
	}

	exports.core.BaseView.prototype.Contain	= 0
	exports.core.BaseView.prototype.Center		= 1


	exports.core.BaseView.prototype._onReset = function() {
		var model = this.model
		var items = this._items
		if (this.trace)
			log("reset", items.length, model.count)

		if (items.length == model.count && items.length == 0)
			return

		if (items.length > model.count) {
			if (model.count != items.length)
				this._onRowsRemoved(model.count, items.length)
			if (items.length > 0)
				this._onRowsChanged(0, items.length)
		} else {
			if (items.length > 0)
				this._onRowsChanged(0, items.length)
			if (model.count != items.length)
				this._onRowsInserted(items.length, model.count)
		}
		if (items.length != model.count)
			throw "reset failed"
		this._delayedLayout.schedule()
	}

	exports.core.BaseView.prototype._onRowsInserted = function(begin, end) {
		if (this.trace)
			log("rows inserted", begin, end)
		var items = this._items
		for(var i = begin; i < end; ++i)
			items.splice(i, 0, null)
		if (items.length != this.model.count)
			throw "insert failed"
		this._delayedLayout.schedule()
	}

	exports.core.BaseView.prototype._onRowsChanged = function(begin, end) {
		if (this.trace)
			log("rows changed", begin, end)
		var items = this._items
		for(var i = begin; i < end; ++i) {
			var item = items[i];
			if (item && item.element)
				item.element.remove()
			items[i] = null
		}
		if (items.length != this.model.count)
			throw "change failed"
		this._delayedLayout.schedule()
	}

	exports.core.BaseView.prototype._onRowsRemoved = function(begin, end) {
		log("rows removed", begin, end)
		var items = this._items
		for(var i = begin; i < end; ++i) {
			var item = items[i];
			if (item && item.element)
				item.element.remove()
			items[i] = null
		}
		items.splice(begin, end - begin)
		if (items.length != this.model.count)
			throw "remove failed"
		this._delayedLayout.schedule()
	}

	exports.core.BaseView.prototype._attach = function() {
		if (this._attached || !this.model || !this.delegate)
			return

		this.model.on('reset', this._onReset.bind(this))
		this.model.on('rowsInserted', this._onRowsInserted.bind(this))
		this.model.on('rowsChanged', this._onRowsChanged.bind(this))
		this.model.on('rowsRemoved', this._onRowsRemoved.bind(this))
		this._attached = true
		this._onReset()
	}

	exports.core.BaseView.prototype._update = function(name, value) {
		switch(name) {
		case 'delegate':
			if (value)
				value.visible = false
			break
		}
		exports.core.Item.prototype._update.apply(this, arguments);
	}

	exports.core.ListView.prototype._layout = function() {
		if (!this.recursiveVisible)
			return

		var model = this.model;
		if (!model)
			return

		this.count = model.count

		var horizontal = this.orientation === this.Horizontal

		var w = this.width, h = this.height
		if (horizontal && w <= 0)
			return

		if (!horizontal && h <= 0)
			return

		var items = this._items
		var n = items.length
		if (!n)
			return

		//log("layout " + n + " into " + w + "x" + h)
		var created = false
		var p = 0
		var c = horizontal? this.content.x: this.content.y
		var size = horizontal? w: h
		var maxW = 0, maxH = 0

		var itemsCount = 0
		//for(var i = 0; i < n && p + c < size; ++i) {
		for(var i = 0; i < n; ++i) {
			var item = items[i]

			if (!item) {
				//if (p + c >= size && itemsCount > 0)
					//break
				var row = this.model.get(i)
				this._local['model'] = row
				this._items[i] = item = this.delegate()
				item.view = this
				item.element.remove()
				this.content.element.append(item.element)
				item._local['model'] = row
				delete this._local['model']
				created = true
			}

			++itemsCount

			var s = (horizontal? item.width: item.height)
			//var visible = (p + c + s >= 0 && p + c < size)

			if (item.x + item.width > maxW)
				maxW = item.width + item.x
			if (item.y + item.height > maxH)
				maxH = item.height + item.y

			if (horizontal)
				item.viewX = p
			else
				item.viewY = p

			if (this.currentIndex == i) {
				this.focusChild(item)
				if (this.contentFollowsCurrentItem)
					this.positionViewAtIndex(i)
			}

			//TODO: show all items because of css transition animation
			//item.visible = visible 
			item.visible = true 
			p += s + this.spacing
		}
		//for( ;i < n; ++i) {
			//var item = items[i]
			//if (item)
				//item.visible = false
		//}
		if (p > 0)
			p -= this.spacing;

		if (itemsCount)
			p *= items.length / itemsCount

		if (horizontal) {
			this.content.width = p
			this.content.height = maxH
			this.contentWidth = p
			this.contentHeight = maxH
		} else {
			this.content.width = maxW
			this.content.height = p
			this.contentWidth = maxW
			this.contentHeight = p
		}
		this.rendered = true
		if (created)
			this._get('context')._completed()
	}

	exports.core.GridView.prototype._layout = function() {
		if (!this.recursiveVisible)
			return

		var model = this.model;
		if (!model)
			return

		this.count = model.count
		if (!this.count)
			return

		var w = this.width, h = this.height
		var horizontal = this.flow == this.FlowLeftToRight

		if (horizontal && w <= 0)
			return

		if (!horizontal && h <= 0)
			return

		var items = this._items
		var n = items.length
		if (!n)
			return

		//log("layout " + n + " into " + w + "x" + h)
		var created = false
		var x = 0, y = 0
		var cx = this.content.x, cy = this.content.y

		var atEnd = function() { return horizontal? cy + y >= h: cx + x >= w }

		var itemsCount = 0
		for(var i = 0; i < n && !atEnd(); ++i) {
			var item = this._items[i]

			if (!item) {
				var row = this.model.get(i)
				this._local['model'] = row
				this._items[i] = item = this.delegate()
				item.view = this
				item.element.remove()
				this.content.element.append(item.element)
				item._local['model'] = row
				delete this._local['model']
				created = true
			}

			++itemsCount

			var visible = horizontal? (cy + y + item.height >= 0 && cy + y < h): (cx + x + item.width >= 0 && cx + x < w)

			item.viewX = x
			item.viewY = y

			if (horizontal) {
				x += this.cellWidth + this.spacing
				if (x > 0 && x + this.cellWidth > w) {
					x = 0
					y += this.cellHeight + this.spacing
				}
			} else {
				y += this.cellHeight + this.spacing
				if (y > 0 && y + this.cellHeight > h) {
					y = 0
					x += this.cellWidth + this.spacing
				}
			}

			if (this.currentIndex == i) {
				this.focusChild(item)
				if (this.contentFollowsCurrentItem)
					this.positionViewAtIndex(i)
			}

			item.visible = visible
		}
		for( ;i < n; ++i) {
			var item = items[i]
			if (item)
				item.visible = false
		}

		if (!horizontal) {
			this.rows = Math.floor((h + this.spacing) / (this.cellHeight + this.spacing))
			this.columns = Math.floor((n + this.rows - 1) / this.rows)
			this.contentWidth = this.content.width = this.columns * (this.cellWidth + this.spacing) - this.spacing
			this.contentHeight = this.content.height = this.rows * (this.cellHeight + this.spacing) - this.spacing
		} else {
			this.columns = Math.floor((w + this.spacing ) / (this.cellWidth + this.spacing))
			this.rows = Math.floor((n + this.columns - 1) / this.columns)
			this.contentWidth = this.columns * (this.cellWidth + this.spacing) - this.spacing
			this.contentHeight = this.rows * (this.cellHeight + this.spacing) - this.spacing
		}
		//console.log(horizontal, w, h, this.rows, this.columns, this.currentIndex, this.contentWidth + "x" + this.contentHeight)
		this.rendered = true
		if (created)
			this._get('context')._completed()
	}

	exports.core.core.Context = function() {
		exports.core.Item.apply(this, null);
		this._started = false
		this._completedHandlers = []
		this._delayedActions = []
	}

	exports.core.core.Context.prototype = Object.create(exports.core.Item.prototype);
	exports.core.core.Context.prototype.constructor = exports.Context;

	exports.core.core.Context.prototype.init = function(html) {
		this._local['context'] = this;

		var win = $(window);
		var w = win.width();
		var h = win.height();
		//log("window size: " + w + "x" + h);

		var body = $('body');
		var div = $(html);
		div.css('visibility', 'hidden');
		body.append(div);
		var userSelect = Modernizr.prefixedCSS('user-select') + ": none; "
		$('head').append($("<style>" +
			"body { overflow-x: hidden; }" +
			"div#context { position: absolute; left: 0px; top: 0px; } " +
			"div.text { width: auto; height: auto} " +
			"div " + "{ position: absolute; border-style: solid; border-width: 0px; white-space: nowrap; border-radius: 0px; opacity: 1.0; transform: none; left: 0px; top: 0px; width: 0px; height: 0px; } " +
			"input { position: absolute; } " +
			"img { position: absolute; -webkit-touch-callout: none; " + userSelect + " } " +
			"</style>"
		));

		this.element = div
		this.width = w;
		this.height = h;

		var proto = exports.core.core.Context.prototype
		core.addProperty(proto, 'bool', 'fullscreen')
		core.addProperty(proto, 'int', 'scrollY')
//		core.addProperty(this, 'int', 'tempCount')
		core.addProperty(proto, 'string', 'hash')
		core.addProperty(proto, 'System', 'system');

		this.system = new exports.core.System(this);

		win.on('resize', function() { this.width = win.width(); this.height = win.height(); }.bind(this));
		win.on('scroll', function(event) { this.scrollY = win.scrollTop(); }.bind(this));
		win.on('hashchange', function(event) { this.hash = window.location.hash; }.bind(this));

		win.on('load', function() {
			log('Context: window.load. calling completed()');
			this._completed();
			div.css('visibility', 'visible');
		} .bind(this) );

		var self = this;
		div.bind('webkitfullscreenchange mozfullscreenchange fullscreenchange', function(e) {
			var state = document.fullScreen || document.mozFullScreen || document.webkitIsFullScreen;
			self.fullscreen = state
		});
		$(document).keydown(function(event) { if (self._processKey(event)) event.preventDefault(); } );
	}

	exports.core.core.Context.prototype._onCompleted = function(callback) {
		this._completedHandlers.push(callback);
	}

	exports.core.core.Context.prototype._update = function(name, value) {
		switch(name) {
			case 'fullscreen': if (value) this._enterFullscreenMode(); else this._exitFullscreenMode(); break
		}
		exports.core.Item.prototype._update.apply(this, arguments)
	}

	exports.core.core.Context.prototype._enterFullscreenMode = function() { return Modernizr.prefixed('requestFullscreen', this.element.get(0))() }
	exports.core.core.Context.prototype._exitFullscreenMode = function() { return Modernizr.prefixed('exitFullscreen', document)() }

	exports.core.core.Context.prototype._inFullscreenMode = function() {
		return !!Modernizr.prefixed('fullscreenElement', document)
	}

	exports.core.core.Context.prototype._completed = function() {
		if (!this._started)
			return

		while(this._completedHandlers.length) {
			var ch = this._completedHandlers
			this._completedHandlers = []
			ch.forEach(function(callback) {
				try {
					callback()
				} catch(ex) {
					log("onCompleted failed:", ex, ex.stack)
				}
			} )
		}
	}

	exports.core.core.Context.prototype.start = function(name) {
		console.log('Context: starting')
		var proto;
		if (typeof name == 'string') {
			//log('creating component...', name);
			var path = name.split('.');
			proto = exports;
			for (var i = 0; i < path.length; ++i)
				proto = proto[path[i]]
		}
		else
			proto = name;
		console.log('Context: creating instance')
		var instance = Object.create(proto.prototype);
		console.log('Context: calling ctor')
		proto.apply(instance, [this]);
		console.log('Context: starting')
		this._started = true
		// console.log('Context: calling on completed')
		// this._completed()
		console.log('Context: signalling layout')
		this.boxChanged()
		console.log('Context: done')
		return instance;
	}

	exports.core.core.Context.prototype._processActions = function() {
		while (this._delayedActions.length) {
			var next = this._delayedActions.shift()
			try {
				next()
			} catch(ex) {
				log('exception in delayed action', ex)
			}
		}
		this._delayedTimeout = undefined
	}

	exports.core.core.Context.prototype.scheduleAction = function(action) {
		var da = this._delayedActions
		this._delayedActions.push(action)
		if (this._delayedTimeout === undefined)
			this._delayedTimeout = setTimeout(this._processActions.bind(this), 0)
	}

	exports.core.core.Context.prototype.qsTr = function(text) {
		var args = arguments
		return text.replace(/%(\d+)/, function(text, index) { return args[index] })
	}
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

	var getStorage = function(obj) {
		var p = obj[storageName]
		return p !== undefined? p: (obj[storageName] = { value : defaultValue })
	}

	Object.defineProperty(proto, name, {
		get: function() {
			var p = this[storageName]
			return p !== undefined?
				p.interpolatedValue !== undefined? p.interpolatedValue: p.value:
				defaultValue
		},

		set: function(newValue) {
			newValue = convert(newValue)
			var p = getStorage(this)
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
		var args = Array.prototype.slice.call(arguments);
		args.splice(0, 0, name);
		self._emitSignal.apply(self, args);
	})
}
