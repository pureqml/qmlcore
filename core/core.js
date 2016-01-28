//samsung guts
var widgetAPI
var tvKey
var pluginAPI

_globals.core.vendor = "webkit"
_globals.trace = { key: false, focus: false }

if ('Common' in window) {
	alert("[QML] samsung smart tv")
	_globals.core.vendor = "samsung"

	log = function() {
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


if ('webOS' in window) {
	log = function() {
		var args = Array.prototype.slice.call(arguments)
		console.log("[QML] " + args.join(" "))
	}

	log("WebOS deteceted")
	_globals.core.vendor = "webos"

	var self = this
	var history = window.history
	history.pushState({ "data": "data" })

	window.addEventListener('popstate', function (event) {
		event.preventDefault()
		history.pushState({ "data": "data" })
		if (!event.state)
			return
		// Emulate 'Back' pressing.
		jQuery.event.trigger({ type: 'keydown', which: 27 })
	});

	log("loaded")
}


if ('tizen' in window) {
	log = function() {
		var args = Array.prototype.slice.call(arguments)
		console.log("[QML] " + args.join(" "))
	}

	log("[QML] Tizen")
	_globals.core.vendor = "tizen"

	log("loaded")
}

if (navigator.userAgent.indexOf('Android') >= 0) {
	log = function() {
		var args = Array.prototype.slice.call(arguments)
		console.log("[QML] " + args.join(" "))
	}
}


var keyCodes
if (_globals.core.vendor == "samsung")
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
} else if (_globals.core.vendor == "tizen") {
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
} else if (_globals.core.vendor == "webos") {
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
} else {
	keyCodes = {
		13: 'Select',
		27: 'Back',
		37: 'Left',
		33: 'PageUp',
		34: 'PageDown',
		38: 'Up',
		39: 'Right',
		40: 'Down',
		112: 'Red',
		113: 'Green',
		114: 'Yellow',
		115: 'Blue'
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

_globals.core.Object = function(parent) {
	this.parent = parent;
	this.children = []
	this._local = {}
	this._changedHandlers = {}
	this._signalHandlers = {}
	this._pressedHandlers = {}
	this._animations = {}
	this._updaters = {}
}

_globals.core.Object.prototype.addChild = function(child) {
	this.children.push(child);
}

_globals.core.Object.prototype._setId = function (name) {
	var p = this;
	while(p) {
		p._local[name] = this;
		p = p.parent;
	}
}

_globals.core.Object.prototype.onChanged = function (name, callback) {
	if (name in this._changedHandlers)
		this._changedHandlers[name].push(callback);
	else
		this._changedHandlers[name] = [callback];
}

_globals.core.Object.prototype.removeOnChanged = function (name, callback) {
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

_globals.core.Object.prototype._removeUpdater = function (name, callback) {
	if (name in this._updaters)
		this._updaters[name]();

	if (callback) {
		this._updaters[name] = callback;
	} else
		delete this._updaters[name]
}

_globals.core.Object.prototype.onPressed = function (name, callback) {
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

_globals.core.Object.prototype._update = function(name, value) {
	if (name in this._changedHandlers) {
		var handlers = this._changedHandlers[name];
		handlers.forEach(function(callback) { try { callback(value) } catch(ex) { log("on " + name + " changed callback failed: ", ex, ex.stack) }})
	}
}

_globals.core.Object.prototype.on = function (name, callback) {
	if (name in this._signalHandlers)
		this._signalHandlers[name].push(callback);
	else
		this._signalHandlers[name] = [callback];
}

_globals.core.Object.prototype._emitSignal = function(name) {
	var args = Array.prototype.slice.call(arguments);
	args.shift();
	if (name in this._signalHandlers) {
		var handlers = this._signalHandlers[name];
		handlers.forEach(function(callback) { try { callback.apply(this, args) } catch(ex) { log("signal " + name + " handler failed:", ex, ex.stack) } });
	}
}

_globals.core.Object.prototype._get = function (name) {
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

_globals.core.Object.prototype.setAnimation = function (name, animation) {
	this._animations[name] = animation;
}

_globals.core.Object.prototype.getAnimation = function (name, animation) {
	var a = this._animations[name]
	return (a && a.enabled())? a: null;
}

_globals.core.Object.prototype._tryFocus = function() { return false }

exports._setup = function() {

	_globals.core.ListModel.prototype.addChild = function(child) {
		this.append(child)
	}

	_globals.core.Timer.prototype._restart = function() {
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

	_globals.core.Animation.prototype.interpolate = blend;

	/** @constructor */
	var Color = function(value) {
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
	_globals.core.Color = Color
	_globals.core.Color.prototype.constructor = _globals.core.Color

	var normalizeColor = function(spec) {
		return (new Color(spec)).get()
	}

	_globals.core.Color.prototype.get = function() {
		return "rgba(" + this.r + "," + this.g + "," + this.b + "," + (this.a / 255) + ")";
	}

	_globals.core.ColorAnimation.prototype.interpolate = function(dst, src, t) {
		var dst_c = new Color(dst), src_c = new Color(src);
		var r = Math.floor(blend(dst_c.r, src_c.r, t))
		var g = Math.floor(blend(dst_c.g, src_c.g, t))
		var b = Math.floor(blend(dst_c.b, src_c.b, t))
		var a = Math.floor(blend(dst_c.a, src_c.a, t))
		return "rgba(" + r + "," + g + "," + b + "," + a + ")";
	}

	_globals.core.Timer.prototype._update = function(name, value) {
		switch(name) {
			case 'running': this._restart(); break;
			case 'interval': this._restart(); break;
			case 'repeat': this._restart(); break;
		}
		_globals.core.Object.prototype._update.apply(this, arguments);
	}

	_globals.core.Item.prototype.toScreen = function() {
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

	_globals.core.Border.prototype._update = function(name, value) {
		switch(name) {
			case 'width': this.parent.element.css({'border-width': value, 'margin-left': -value, 'margin-top': -value}); break;
			case 'color': this.parent.element.css('border-color', normalizeColor(value)); break;
		}
		_globals.core.Object.prototype._update.apply(this, arguments);
	}

	_globals.core.BorderMargin.prototype._updateStyle = function() {
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

	_globals.core.BorderMargin.prototype._update = function(name, value) {
		switch(name) {
			case 'margin': this._updateStyle(); break
			case 'color': this._updateStyle(); break
		}
		_globals.core.Object.prototype._update.apply(this, arguments);
	}

	_globals.core.Shadow.prototype._update = function(name, value) {
		this.parent._updateStyle()
		_globals.core.Object.prototype._update.apply(this, arguments);
	}

	_globals.core.Shadow.prototype._empty = function() {
		return !this.x && !this.y && !this.blur && !this.spread;
	}

	_globals.core.Shadow.prototype._getFilterStyle = function() {
		var style = this.x + "px " + this.y + "px " + this.blur + "px "
		if (this.spread > 0)
			style += this.spread + "px "
		style += new Color(this.color).get()
		return style
	}

	_globals.core.Effects.prototype._addStyle = function(property, style, units) {
		var value = this[property]
		if (!value)
			return ''
		return (style || property) + '(' + value + (units || '') + ') '
	}

	_globals.core.Effects.prototype._getFilterStyle = function() {
		var style = []
		style += this._addStyle('blur', 'blur', 'px')
		style += this._addStyle('grayscale')
		style += this._addStyle('sepia')
		style += this._addStyle('brightness')
		style += this._addStyle('contrast')
		style += this._addStyle('hueRotate', 'hue-rotate', 'deg')
		style += this._addStyle('invert')
		style += this._addStyle('saturate')
		return style
	}

	_globals.core.Effects.prototype._updateStyle = function() {
		var style = this._getFilterStyle()
		var el = this.parent.element
		if (el) {
			el.css('-webkit-filter', style)
			if (this.shadow && !this.shadow._empty())
				el.css('box-shadow', this.shadow._getFilterStyle())
		}
	}

	_globals.core.Effects.prototype._update = function(name, value) {
		this._updateStyle()
		_globals.core.Object.prototype._update.apply(this, arguments)
	}

	_globals.core.Item.prototype.addChild = function(child) {
		_globals.core.Object.prototype.addChild.apply(this, arguments)
		if (child._tryFocus())
			child._propagateFocusToParents()
	}

	_globals.core.Item.prototype._update = function(name, value) {
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
				value = this.x + this.viewX
				this.element.css('left', value);
				this.boxChanged()
				break;

			case 'y':
			case 'viewY':
				value = this.y + this.viewY
				this.element.css('top', value);
				this.boxChanged()
				break;

			case 'opacity': if (this.element) /*FIXME*/this.element.css('opacity', value); break;
			case 'recursiveVisible': if (this.element) /*FIXME*/this.element.css('visibility', value? 'visible': 'hidden'); break;
			case 'z':		this.element.css('z-index', value); break;
			case 'radius':	this.element.css('border-radius', value); break;
			case 'clip':	this.element.css('overflow', value? 'hidden': 'visible'); break
		}
		_globals.core.Object.prototype._update.apply(this, arguments);
	}

	_globals.core.Item.prototype._updateVisibility = function() {
		var visible = this.hasOwnProperty('visible')? this.visible: true
		var opacity = this.hasOwnProperty('opacity')? this.opacity: 1.0
		this.recursiveVisible = this._recursiveVisible && this.visible && this.opacity > 0.004 //~1/255
		if (!visible && this.parent)
			this.parent._tryFocus() //try repair local focus on visibility changed
	}

	_globals.core.Item.prototype.forceActiveFocus = function() {
		var item = this;
		while(item.parent) {
			item.parent._focusChild(item);
			item = item.parent;
		}
	}

	_globals.core.Item.prototype._tryFocus = function() {
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

	_globals.core.Item.prototype._propagateFocusToParents = function() {
		var item = this;
		while(item.parent && (!item.parent.focusedChild || !item.parent.focusedChild.visible)) {
			item.parent._focusChild(item)
			item = item.parent
		}
	}
	_globals.core.Item.prototype.hasActiveFocus = function() {
		var item = this
		while(item.parent) {
			if (item.parent.focusedChild != item)
				return false

			item = item.parent
		}
		return true
	}

	_globals.core.Item.prototype._focusTree = function(active) {
		this.activeFocus = active;
		if (this.focusedChild)
			this.focusedChild._focusTree(active);
	}

	_globals.core.Item.prototype._focusChild = function (child) {
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

	_globals.core.Item.prototype.focusChild = function(child) {
		this._propagateFocusToParents()
		this._focusChild(child)
	}

	_globals.core.Item.prototype._processKey = function (event) {
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
							if (_globals.trace.key)
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
							if (_globals.trace.key)
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

	_globals.core.MouseArea.prototype._updatePosition = function(event) {
		if (!this.recursiveVisible)
			return

		var box = this.toScreen()
		var x = event.pageX - box[0]
		var y = event.pageY - box[1]

		if (x >= 0 && y >= 0 && x < this.width && y < this.height)
		{
			this.mouseX = x
			this.mouseY = y
			return true
		}
		else
			return false
	}

	_globals.core.GamepadManager.prototype._gpButtonsPollInterval

	_globals.core.GamepadManager.prototype._gpButtonCheckLoop = function(self) {
		clearInterval(self._gpButtonsPollInterval);
		var gamepads = navigator.getGamepads ? navigator.getGamepads() : (navigator.webkitGetGamepads ? navigator.webkitGetGamepads : []);
		for (var i in gamepads) {
			if (!gamepads[i] || !gamepads[i].buttons)
				continue

			var gp = gamepads[i]
			var gpItem

			for (var i = 0; i < this.children.length; ++i) {
				var c = this.children[i]
				if (c instanceof qml.core.Gamepad && c.connected && c.index == gp.index) {
					gpItem = c
					break
				}
			}

			if (!gp || !gpItem)
				continue

			var event = { type: 'keydown', 'source': 'gamepad', 'index': gp.index }

			if (gp.axes && gp.axes.length >= 4) {
				// Left joystick.
				if (gp.axes[0])
					gpItem.leftJoystickX(gp.axes[0])
				if (gp.axes[1])
					gpItem.leftJoystickY(gp.axes[1])

				// Right joystick.
				if (gp.axes[2])
					gpItem.rightJoystickX(gp.axes[2])
				if (gp.axes[3])
					gpItem.rightJoystickY(gp.axes[3])
			}

			if (gp.buttons.length >= 16) {
				// Functional buttons.
				if (gp.buttons[0].pressed)
					event.which = 114
				else if (gp.buttons[1].pressed)
					event.which = 112
				else if (gp.buttons[2].pressed)
					event.which = 113
				else if (gp.buttons[3].pressed)
					event.which = 115
				// Trigger buttons.
				else if (gp.buttons[4].pressed)
					log("button 4")
				else if (gp.buttons[5].pressed)
					log("button 5")
				else if (gp.buttons[6].pressed)
					log("button 6")
				else if (gp.buttons[7].pressed)
					log("button 7")
				// Select button.
				else if (gp.buttons[8].pressed)
					event.which = 27
				// Start button.
				else if (gp.buttons[9].pressed)
					log("button 9")
				// Left joystick.
				else if (gp.buttons[10].pressed)
					event.which = 13
				// Right joystick.
				else if (gp.buttons[11].pressed)
					event.which = 13
				// Navigation keys.
				else if (gp.buttons[12].pressed)
					event.which = 38
				else if (gp.buttons[13].pressed)
					event.which = 40
				else if (gp.buttons[14].pressed)
					event.which = 37
				else if (gp.buttons[15].pressed)
					event.which = 39
			}

			if (gp.buttons.length >= 17) {
				if (gp.buttons[16].pressed)
					log("button 16")
			}

			if (event.which)
				jQuery.event.trigger("keypress", event)
		}
		this._gpButtonsPollInterval = setInterval( function() { self._gpButtonCheckLoop(self) }, 250)
	}

	_globals.core.GamepadManager.prototype._onGamepadConnected = function(event) {
		if (!this._gamepads) 
			this._gamepads = {}

		var children = this.children
		var g = event.gamepad

		for (var i = 0; i < children.length; ++i) {
			var c = children[i]
			if (c instanceof qml.core.Gamepad && !c.connected) {
				c.index = g.index
				c.connected = true
				c.deviceInfo = g.id
				c.buttonsCount = g.buttons.length
				c.axesCount = g.axes.length
				break
			}
		}

		this._gamepads[event.gamepad.index] = event.gamepad
		if (++this.count == 1)
			this._gpButtonCheckLoop(this)
	}

	_globals.core.GamepadManager.prototype._onGamepadDisconnected = function(event) {
		var g = event.gamepad
		var children = this.children

		for (var i = 0; i < children.length; ++i) {
			var c = children[i]
			if (c instanceof qml.core.Gamepad && c.index == g.index) {
				c.index = -1
				c.connected = false
				c.deviceInfo = ""
				c.buttonsCount = 0
				c.axesCount = 0
				break
			}
		}
		delete this._gamepads[event.gamepad.index]
		--this.count
	}

	_globals.core.MouseArea.prototype._onSwipe = function(event) {
		if (!this.hoverEnabled || !this.recursiveVisible || !('ontouchstart' in window))
			return

		this.pressed = !event.end
		if (event.orientation == "vertical")
			this.verticalSwiped(event)
		else
			this.horizontalSwiped(event)

		event.preventDefault()
	}

	_globals.core.MouseArea.prototype._onClick = function(event) {
		if (!this.recursiveVisible)
			return

		this._updatePosition(event)
		this.clicked()
	}

	_globals.core.MouseArea.prototype._onEnter = function(event) {
		if (!this.hoverEnabled || !this.recursiveVisible)
			return

		this._updatePosition(event)
		this.containsMouse = true
	}

	_globals.core.MouseArea.prototype._onExit = function(event) {
		if (!this.hoverEnabled || !this.recursiveVisible)
			return

		this._updatePosition(event)
		this.containsMouse = false
		if (this.pressed) {
			this.pressed = false
			this.canceled()
		}
	}

	_globals.core.MouseArea.prototype._onMove = function(event) {
		if (!this.hoverEnabled || !this.recursiveVisible)
			return

		if (this._updatePosition(event))
			event.preventDefault()
	}

	_globals.core.MouseArea.prototype._onDown = function(event) {
		this._updatePosition(event)
		this.pressed = true
	}

	_globals.core.MouseArea.prototype._onUp = function(event) {
		this._updatePosition(event)
		this.pressed = false
	}

	_globals.core.MouseArea.prototype._onWheel = function(event) {
		var e = event.originalEvent
		this.wheelEvent(e.wheelDelta / 120)
	}

	_globals.core.AnchorLine.prototype.toScreen = function() {
		return this.parent.toScreen()[this.boxIndex]
	}

	_globals.core.Anchors.prototype._update = function(name) {
		var self = this.parent;
		var parent = self.parent;
		var anchors = this;

		var update_left = function() {
			var parent_box = parent.toScreen();
			var left = anchors.left.toScreen();
			var lm = anchors.leftMargin || anchors.margins;
			self.x = left + lm - parent_box[0] - self.viewX;
			if (anchors.right) {
				var right = anchors.right.toScreen();
				var rm = anchors.rightMargin || anchors.margins;
				self.width = right - left - rm - lm;
			}
		};

		var update_right = function() {
			var parent_box = parent.toScreen();
			var right = anchors.right.toScreen();
			var lm = anchors.leftMargin || anchors.margins;
			var rm = anchors.rightMargin || anchors.margins;
			if (anchors.left) {
				var left = anchors.left.toScreen();
				self.width = right - left - rm - lm;
			}
			self.x = right - parent_box[0] - rm - self.width - self.viewX;
		};

		var update_top = function() {
			var parent_box = parent.toScreen();
			var top = anchors.top.toScreen()
			var tm = anchors.topMargin || anchors.margins;
			var bm = anchors.bottomMargin || anchors.margins;
			self.y = top + tm - parent_box[1] - self.viewY;
			if (anchors.bottom) {
				var bottom = anchors.bottom.toScreen();
				self.height = bottom - top - bm - tm;
			}
		}

		var update_bottom = function() {
			var parent_box = parent.toScreen();
			var bottom = anchors.bottom.toScreen();
			var tm = anchors.topMargin || anchors.margins;
			var bm = anchors.bottomMargin || anchors.margins;
			if (anchors.top) {
				var top = anchors.top.toScreen()
				self.height = bottom - top - bm - tm;
			}
			self.y = bottom - parent_box[1] - bm - self.height - self.viewY;
		}

		var update_h_center = function() {
			var parent_box = parent.toScreen();
			var hcenter = anchors.horizontalCenter.toScreen();
			var lm = anchors.leftMargin || anchors.margins;
			var rm = anchors.rightMargin || anchors.margins;
			self.x = hcenter - self.width / 2 - parent_box[0] + lm - rm - self.viewX;
		}

		var update_v_center = function() {
			var parent_box = parent.toScreen();
			var vcenter = anchors.verticalCenter.toScreen();
			var tm = anchors.topMargin || anchors.margins;
			var bm = anchors.bottomMargin || anchors.margins;
			self.y = vcenter - self.height / 2 - parent_box[1] + tm - bm - self.viewY;
		}

		switch(name) {
			case 'left':
				update_left();
				anchors.left.parent.on('boxChanged', update_left);
				anchors.onChanged('leftMargin', update_left);
				break;

			case 'right':
				update_right()
				self.onChanged('width', update_right)
				anchors.right.parent.on('boxChanged', update_right)
				anchors.onChanged('rightMargin', update_right)
				break;

			case 'top':
				update_top()
				anchors.top.parent.on('boxChanged', update_top)
				anchors.onChanged('topMargin', update_top)
				break;

			case 'bottom':
				update_bottom();
				self.onChanged('height', update_bottom)
				anchors.bottom.parent.on('boxChanged', update_bottom);
				anchors.onChanged('bottomMargin', update_bottom);
				break;

			case 'horizontalCenter':
				update_h_center();
				self.onChanged('width', update_h_center);
				anchors.onChanged('leftMargin', update_h_center);
				anchors.onChanged('rightMargin', update_h_center);
				anchors.horizontalCenter.parent.on('boxChanged', update_h_center);
				break;

			case 'verticalCenter':
				update_v_center()
				self.onChanged('height', update_v_center)
				anchors.onChanged('topMargin', update_v_center)
				anchors.onChanged('bottomMargin', update_v_center)
				anchors.verticalCenter.parent.on('boxChanged', update_v_center)
				break;

			case 'fill':
				anchors.left = anchors.fill.left;
				anchors.right = anchors.fill.right;
				anchors.top = anchors.fill.top;
				anchors.bottom = anchors.fill.bottom;
				break;

			case 'centerIn':
				anchors.horizontalCenter = anchors.centerIn.horizontalCenter;
				anchors.verticalCenter = anchors.centerIn.verticalCenter;
				break;
		}
		_globals.core.Object.prototype._update.apply(this, arguments);
	}

	_globals.core.Font.prototype._update = function(name, value) {
		switch(name) {
			case 'family':		this.parent.element.css('font-family', value); this.parent._updateSize(); break
			case 'pointSize':	this.parent.element.css('font-size', value + "pt"); this.parent._updateSize(); break
			case 'pixelSize':	this.parent.element.css('font-size', value + "px"); this.parent._updateSize(); break
			case 'italic': 		this.parent.element.css('font-style', value? 'italic': 'normal'); this.parent._updateSize(); break
			case 'bold': 		this.parent.element.css('font-weight', value? 'bold': 'normal'); this.parent._updateSize(); break
			case 'underline':	this.parent.element.css('text-decoration', value? 'underline': ''); this.parent._updateSize(); break
			case 'shadow':		this.parent.element.css('text-shadow', value? '2px 2px black': 'none'); this.parent._updateSize(); break;
		}
		_globals.core.Object.prototype._update.apply(this, arguments);
	}

	_globals.core.Text.prototype.AlignLeft		= 0
	_globals.core.Text.prototype.AlignRight		= 1
	_globals.core.Text.prototype.AlignHCenter	= 2
	_globals.core.Text.prototype.AlignJustify	= 3

	_globals.core.Text.prototype.AlignTop		= 0
	_globals.core.Text.prototype.AlignBottom	= 1
	_globals.core.Text.prototype.AlignVCenter	= 2

	_globals.core.Text.prototype._updateSize = function() {
		var oldW = this.element.css('width')
		var oldH = this.element.css('height')
		this.element.css('width', '')
		this.element.css('height', '')
		var w = this.element.width();
		var h = this.element.height();
		this.element.css('width', oldW)
		this.element.css('height', oldH)
		this.paintedWidth = w;
		this.paintedHeight = h;
		switch(this.verticalAlignment) {
		case this.AlignTop:		this.element.css('margin-top', 0); break
		case this.AlignBottom:	this.element.css('margin-top', this.height - this.paintedHeight); break
		case this.AlignVCenter:	this.element.css('margin-top', (this.height - this.paintedHeight) / 2); break
		}
	}

	_globals.core.Text.prototype._update = function(name, value) {
		switch(name) {
			case 'text': this.element.text(value); this._updateSize(); break;
			case 'color': this.element.css('color', normalizeColor(value)); break;
			case 'wrap': this.element.css('white-space', value? 'normal': 'nowrap'); break;
			case 'verticalAlignment': this.verticalAlignment = value; this._updateSize(); break
			case 'horizontalAlignment':
				switch(value) {
				case this.AlignLeft:	this.element.css('text-align', 'left'); break
				case this.AlignRight:	this.element.css('text-align', 'right'); break
				case this.AlignHCenter:	this.element.css('text-align', 'center'); break
				case this.AlignJustify:	this.element.css('text-align', 'justify'); break
				}
				break
		}
		_globals.core.Item.prototype._update.apply(this, arguments);
	}

	_globals.core.Gradient.prototype.addChild = function(child) {
		this.stops.push(child)
		this.stops.sort(function(a, b) { return a.position > b.position; })
	}

	_globals.core.GradientStop.prototype._update = function() {
		this.parent.parent._update('gradient', this.parent)
	}

	_globals.core.GradientStop.prototype._getDeclaration = function() {
		return normalizeColor(this.color) + " " + Math.floor(100 * this.position) + "%"
	}

	_globals.core.Gradient.prototype.Vertical = 0
	_globals.core.Gradient.prototype.Horizontal = 1

	_globals.core.Gradient.prototype._getDeclaration = function() {
		var decl = []
		var orientation = this.orientation == this.Vertical? 'top': 'left'
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

	_globals.core.Rectangle.prototype._update = function(name, value) {
		switch(name) {
			case 'color': this.element.css('background-color', normalizeColor(value)); break;
			case 'gradient': {
				if (value) {
					var decl = value._getDeclaration()
					this.element.css('background-color', '')
					//this.element.css('background', 'linear-gradient(to ' + decl + ')')
					this.element.css('background', '-o-linear-gradient(' + decl + ')')
					this.element.css('background', '-moz-linear-gradient(' + decl + ')')
					this.element.css('background', '-webkit-linear-gradient(' + decl + ')')
					this.element.css('background', '-ms-linear-gradient(' + decl + ')')
				} else {
					this.element.css('background', '')
					this._update('color', normalizeColor(this.color)) //restore color
				}
				break;
			}
		}
		_globals.core.Item.prototype._update.apply(this, arguments);
	}

	_globals.core.Image.prototype.Null = 0;
	_globals.core.Image.prototype.Ready = 1;
	_globals.core.Image.prototype.Loading = 2;
	_globals.core.Image.prototype.Error = 3;

	_globals.core.Image.prototype.Stretch = 0;
	_globals.core.Image.prototype.PreserveAspectFit = 1;
	_globals.core.Image.prototype.PreserveAspectCrop = 2;
	_globals.core.Image.prototype.Tile = 3;
	_globals.core.Image.prototype.TileVertically = 4;
	_globals.core.Image.prototype.TileHorizontally = 5;

	_globals.core.Image.prototype._onLoad = function() {
		var image = this
		var tmp = new Image()
		tmp.src = this.source
		image.element.css('border-radius', '0')

		tmp.onload = function() {
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
	}

	_globals.core.Image.prototype._onError = function() {
		this.status = this.Error;
	}

	_globals.core.Image.prototype._update = function(name, value) {
		switch(name) {
			case 'width':
			case 'height':
			case 'fillMode': this._onLoad(); break;
			case 'source':
				this.status = value ? this.Loading : this.Null;
				if (value)
					this._onLoad();
				break;
		}
		_globals.core.Item.prototype._update.apply(this, arguments);
	}

	_globals.core.Row.prototype._layout = function() {
		var children = this.children;
		var p = 0
		var h = 0
		for(var i = 0; i < children.length; ++i) {
			var c = children[i]
			if (!c.hasOwnProperty('height'))
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

	_globals.core.Row.prototype.addChild = function(child) {
		_globals.core.Item.prototype.addChild.apply(this, arguments)
		child.onChanged('recursiveVisible', this._layout.bind(this))
		child.onChanged('width', this._layout.bind(this))
	}

	_globals.core.Column.prototype._layout = function() {
		var children = this.children;
		var p = 0
		var w = 0
		for(var i = 0; i < children.length; ++i) {
			var c = children[i]
			if (!c.hasOwnProperty('height'))
				continue
			var r = c.x + c.width
			if (r > w)
				w = r
			c.viewY = p
			if (c.recursiveVisible)
				p += c.height + this.spacing
		}
		if (p > 0)
			p -= this.spacing
		this.contentWidth = w
		this.contentHeight = p
	}

	_globals.core.Column.prototype.addChild = function(child) {
		_globals.core.Item.prototype.addChild.apply(this, arguments)
		child.onChanged('height', this._layout.bind(this))
		child.onChanged('recursiveVisible', this._layout.bind(this))
	}


	_globals.core.BaseView.prototype.Contain	= 0
	_globals.core.BaseView.prototype.Center		= 1


	_globals.core.BaseView.prototype._onReset = function() {
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
		this._layout()
	}

	_globals.core.BaseView.prototype._onRowsInserted = function(begin, end) {
		if (this.trace)
			log("rows inserted", begin, end)
		var items = this._items
		for(var i = begin; i < end; ++i)
			items.splice(i, 0, null)
		if (items.length != this.model.count)
			throw "insert failed"
		this._layout()
	}

	_globals.core.BaseView.prototype._onRowsChanged = function(begin, end) {
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
		this._layout()
	}

	_globals.core.BaseView.prototype._onRowsRemoved = function(begin, end) {
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
		this._layout()
	}

	_globals.core.BaseView.prototype._attach = function() {
		if (this._attached || !this.model || !this.delegate)
			return

		this.model.on('reset', this._onReset.bind(this))
		this.model.on('rowsInserted', this._onRowsInserted.bind(this))
		this.model.on('rowsChanged', this._onRowsChanged.bind(this))
		this.model.on('rowsRemoved', this._onRowsRemoved.bind(this))
		this._attached = true
		this._onReset()
	}

	_globals.core.BaseView.prototype._update = function(name, value) {
		switch(name) {
		case 'delegate':
			if (value)
				value.visible = false
			break
		}
		_globals.core.Item.prototype._update.apply(this, arguments);
	}


	_globals.core.ListView.prototype.Vertical	= 0
	_globals.core.ListView.prototype.Horizontal	= 1


	_globals.core.ListView.prototype._layout = function() {
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
		for(var i = 0; i < n && p + c < size; ++i) {
			var item = items[i]

			if (!item) {
				if (p + c >= size && itemsCount > 0)
					break
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
			var visible = (p + c + s >= 0 && p + c < size)

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

			item.visible = visible
			p += s + this.spacing
		}
		for( ;i < n; ++i) {
			var item = items[i]
			if (item)
				item.visible = false
		}
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
		if (created)
			this._get('renderer')._completed()
	}

	_globals.core.GridView.prototype.FlowLeftToRight	= 0
	_globals.core.GridView.prototype.FlowTopToBottom	= 1

	_globals.core.GridView.prototype._layout = function() {
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
				x += this.cellWidth
				if (x > 0 && x + this.cellWidth > w) {
					x = 0
					y += this.cellHeight
				}
			} else {
				y += this.cellHeight
				if (y > 0 && y + this.cellHeight > h) {
					y = 0
					x += this.cellWidth
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
			this.rows = Math.floor(h / this.cellHeight)
			this.columns = Math.floor((n + this.rows - 1) / this.rows)
			this.contentWidth = this.content.width = this.columns * this.cellWidth
			this.contentHeight = this.content.height = this.rows * this.cellHeight
		} else {
			this.columns = Math.floor(w / this.cellWidth)
			this.rows = Math.floor((n + this.columns - 1) / this.columns)
			this.contentWidth = this.columns * this.cellWidth
			this.contentHeight = this.rows * this.cellHeight
		}
		//console.log(horizontal, w, h, this.rows, this.columns, this.currentIndex, this.contentWidth + "x" + this.contentHeight)
		if (created)
			this._get('renderer')._completed()
	}

	_globals.core.core.Context = function() {
		_globals.core.Item.apply(this, null);
		this._started = false
		this._completedHandlers = []
	}

	_globals.core.core.Context.prototype = Object.create(_globals.core.Item.prototype);
	_globals.core.core.Context.prototype.constructor = exports.Context;

	_globals.core.core.Context.prototype.init = function() {
		this._local['renderer'] = this;

		var win = $(window);
		var w = win.width();
		var h = win.height();
		//log("window size: " + w + "x" + h);

		var body = $('body');
		var div = $("<div id='renderer'></div>");
		body.append(div);
		$('head').append($("<style>" +
			"body { overflow: hidden; }" +
			"div#renderer { position: absolute; left: 0px; top: 0px; } " +
			"div { position: absolute; border-style: solid; border-width: 0px; white-space: nowrap; } " +
			"input { position: absolute; } " +
			"img { position: absolute; -webkit-touch-callout: none; -webkit-user-select: none; -khtml-user-select: none; -moz-user-select: none; -ms-user-select: none; user-select: none; content: ''; } " +
			"</style>"
		));

		this.element = div
		this.width = w;
		this.height = h;

		core.addProperty(this, 'bool', 'fullscreen')

		win.on('resize', function() { this.width = win.width(); this.height = win.height(); }.bind(this));

		var self = this;
		div.bind('webkitfullscreenchange mozfullscreenchange fullscreenchange', function(e) {
			var state = document.fullScreen || document.mozFullScreen || document.webkitIsFullScreen;
			self.fullscreen = state
		});
		$(document).keydown(function(event) { if (self._processKey(event)) event.preventDefault(); } );
	}

	_globals.core.core.Context.prototype._onCompleted = function(callback) {
		this._completedHandlers.push(callback);
	}

	_globals.core.core.Context.prototype._update = function(name, value) {
		switch(name) {
			case 'fullscreen': if (value) this._enterFullscreenMode(); else this._exitFullscreenMode(); break
		}
		_globals.core.Item.prototype._update.apply(this, arguments)
	}

	_globals.core.core.Context.prototype._enterFullscreenMode = function() {
		var elem = this.element.get(0)
		if (elem.requestFullscreen)
			elem.requestFullscreen()
		else if (elem.msRequestFullscreen)
			elem.msRequestFullscreen()
		else if (elem.mozRequestFullScreen)
			elem.mozRequestFullScreen()
		else if (elem.webkitRequestFullscreen)
			elem.webkitRequestFullscreen()
		else
			console.log("no requestFullscreen api: ", elem)
	}

	_globals.core.core.Context.prototype._exitFullscreenMode = function() {
		if (document.exitFullscreen)
			document.exitFullscreen()
		else if (document.msExitFullscreen)
			document.msExitFullscreen();
		else if (document.mozCancelFullScreen)
			document.mozCancelFullScreen()
		else if (document.webkitExitFullscreen)
			document.webkitExitFullscreen()
		else
			console.log("no exitFullscreen api")
	}

	_globals.core.core.Context.prototype._inFullscreenMode = function() {
		return !!(document.fullscreenElement ||    // alternative standard method
			document.mozFullScreenElement ||
			document.webkitFullscreenElement ||
			document.msFullscreenElement)
	}

	_globals.core.core.Context.prototype._completed = function() {
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

	_globals.core.core.Context.prototype.start = function(name) {
		console.log('Context: starting')
		var proto;
		if (typeof name == 'string') {
			//log('creating component...', name);
			var path = name.split('.');
			proto = _globals;
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
		console.log('Context: calling on completed')
		this._completed()
		console.log('Context: signalling layout')
		this.boxChanged()
		console.log('Context: done')
		return instance;
	}
}

exports.addProperty = function(self, type, name) {
	var value;
	var timer;
	var timeout;
	var interpolated_value;
	switch(type) {
		case 'int':			value = 0; break;
		case 'bool':		value = false; break;
		case 'real':		value = 0.0; break;
		case 'string':		value = ""; break
		case 'array':		value = []; break
		default: if (type[0].toUpperCase() == type[0]) value = null; break;
	}
	var convert = function(value) {
		switch(type) {
		case 'int':		return Math.floor(value);
		case 'bool':	return value? true: false;
		case 'string':	return String(value);
		default:		return value;
		}
	}
	Object.defineProperty(self, name, {
		get: function() {
			return interpolated_value !== undefined? interpolated_value: value;
		},
		set: function(newValue) {
			if (!self.getAnimation) {
				log("bound unknown object", self)
				throw "invalid object";
			}
			newValue = convert(newValue)
			var animation = self.getAnimation(name)
			if (animation && value !== newValue) {
				if (timer)
					clearInterval(timer);
				if (timeout)
					clearTimeout(timeout);

				var duration = animation.duration;
				var date = new Date();
				var started = date.getTime() + date.getMilliseconds() / 1000.0;

				var src = interpolated_value !== undefined? interpolated_value: value;
				var dst = newValue;
				timer = setInterval(function() {
					var date = new Date();
					var now = date.getTime() + date.getMilliseconds() / 1000.0;
					var t = 1.0 * (now - started) / duration;
					if (t >= 1)
						t = 1;

					interpolated_value = convert(animation.interpolate(dst, src, t));
					self._update(name, interpolated_value, src);
				}, 0);

				var complete = function() {
					clearInterval(timer);
					interpolated_value = undefined;
					self._update(name, dst, src);
				}

				timeout = setTimeout(complete, duration);
				animation.complete = complete;
			}
			var oldValue = value;
			if (oldValue !== newValue) {
				value = newValue;
				if (!animation)
					self._update(name, newValue, oldValue);
			}
		},
		enumerable: true
	});
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

exports._bootstrap = function(self, name) {
	switch(name) {
		case 'core.ListModel':
			self._rows = []
			break;
		case 'core.BaseView':
			self._items = []
			break;
		case 'core.Gradient':
			self.stops = []
			break
		case 'core.Animation':
			self._disabled = 0
			break
		case 'core.Item':
			if (!self.parent) //top-level item, do not create item
				break;
			if (self.element)
				throw "double ctor call";
			self.element = $('<div/>');
			self.parent.element.append(self.element);
			var updateVisibility = function(value) {
				self._recursiveVisible = value
				self._updateVisibility()
			}
			updateVisibility(self.parent.recursiveVisible)
			self.parent.onChanged('recursiveVisible', updateVisibility)

			break;
		case 'core.GamepadManager':
			var gpPollInterval
			if (!('ongamepadconnected' in window))
				gpPollInterval = setInterval(pollGamepads, 1000)

			function pollGamepads() {
				clearInterval(gpPollInterval)
				var gamepads = navigator.getGamepads ? navigator.getGamepads() : (navigator.webkitGetGamepads ? navigator.webkitGetGamepads : []);
				for (var i = 0; i < gamepads.length; ++i) {
					var gamepad = gamepads[i]
					if (gamepad)
						self._onGamepadConnected({ 'gamepad': gamepad })
				}
			}
			window.addEventListener('gamepadconnected', self._onGamepadConnected.bind(self));
			window.addEventListener('gamepaddisconnected', self._onGamepadDisconnected.bind(self));
			break;
		case 'core.MouseArea':
			self.element.click(self._onClick.bind(self))
			if (self.element.drag)
				self.element.drag(self._onSwipe.bind(self))
			$(document).mousemove(self._onMove.bind(self))
			self.element.hover(self._onEnter.bind(self), self._onExit.bind(self)) //fixme: unsubscribe
			self.element.mousedown(self._onDown.bind(self))
			self.element.mouseup(self._onUp.bind(self))
			self.element.on('mousewheel', self._onWheel.bind(self))
			break;
		case 'core.Image':
			self.element.remove();
			self.element = $('<div/>');
			self.parent.element.append(self.element);
			self.element.on('load', self._onLoad.bind(self));
			self.element.on('error', self._onError.bind(self));
			break;
	}
}
