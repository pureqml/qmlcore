/* qml.core javascript code */

var keyCodes = {
	13: 'Select',
	37: 'Left',
	38: 'Up',
	39: 'Right',
	40: 'Down'
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
	'gray':		'080808'
}

_globals.core.Object = function(parent) {
	this.parent = parent;
	this._local = {}
	this._changedHandlers = {}
	this._eventHandlers = {}
	this._pressedHandlers = {}
	this._animations = {}
	this._updaters = {}
}

_globals.core.Object.prototype.children = []

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
	if (name in this._pressedHandlers)
		this._pressedHandlers[name].push(callback);
	else
		this._pressedHandlers[name] = [callback];
}

_globals.core.Object.prototype._update = function(name, value) {
	if (name in this._changedHandlers) {
		var handlers = this._changedHandlers[name];
		handlers.forEach(function(callback) { callback(value); });
	}
}

_globals.core.Object.prototype.on = function (name, callback) {
	if (name in this._eventHandlers)
		this._eventHandlers[name].push(callback);
	else
		this._eventHandlers[name] = [callback];
}

_globals.core.Object.prototype._emitEvent = function(name) {
	var args = Array.prototype.slice.call(arguments);
	args.shift();
	if (name in this._eventHandlers) {
		var handlers = this._eventHandlers[name];
		handlers.forEach(function(callback) { callback.apply(this, args); });
	}
}

_globals.core.Object.prototype.get = function (name) {
	if (this.hasOwnProperty(name))
		return this[name];
	var object = this;
	while(object) {
		if (name in object._local)
			return object._local[name];
		object = object.parent;
	}
	console.log(name, this);
	throw ("invalid property requested: '" + name + "' in context of " + this);
}

_globals.core.Object.prototype.setAnimation = function (name, animation) {
	this._animations[name] = animation;
}

_globals.core.Object.prototype.getAnimation = function (name, animation) {
	return this._animations[name] || null;
}

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

		//console.log("starting timer", this.interval, this.repeat);
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

	_globals.core.Color = function(value) {
		if (value.substring(0, 4) == "rgba") {
			var b = value.indexOf('('), e = value.lastIndexOf(')')
			value = value.substring(b + 1, e).split(',')
			this.r = parseInt(value[0])
			this.g = parseInt(value[1])
			this.b = parseInt(value[2])
			this.a = parseInt(value[3])
			return
		}
		else {
			var h = value.charAt(0);
			if (h != '#')
				triplet = colorTable[value];
			else
				triplet = value.substring(1)
		}

		if (!triplet)
			throw "invalid color specification: " + value

		var len = triplet.length;
		if (len == 3 || len == 4) {
			var r = parseInt(triplet.charAt(0), 16)
			var g = parseInt(triplet.charAt(1), 16)
			var b = parseInt(triplet.charAt(2), 16)
			var a = (len == 4)? parseInt(triplet.charAt(3), 16): 255
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
	_globals.core.Color.prototype.constructor = _globals.core.Color;

	_globals.core.ColorAnimation.prototype.interpolate = function(dst, src, t) {
		var dst_c = new _globals.core.Color(dst), src_c = new _globals.core.Color(src);
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
		var item = this;
		var x = 0, y = 0;
		while(item) {
			x += item.x;
			y += item.y;
			item = item.parent;
		}
		return [x, y];
	}

	_globals.core.Border.prototype._update = function(name, value) {
		switch(name) {
			case 'width': this.parent.element.css({'border-width': value, 'margin-left': -value, 'margin-top': -value}); break;
			case 'color': this.parent.element.css('border-color', value); break;
		}
		_globals.core.Object.prototype._update.apply(this, arguments);
	}

	_globals.core.Item.prototype._update = function(name, value) {
		switch(name) {
			case 'width':
				this.element.css('width', value);
				this.right.value = this.left.value + value;
				this.horizontalCenter.value = (this.right.value + this.left.value) / 2;
				break;

			case 'height':
				this.element.css('height', value);
				this.bottom.value = this.top.value + value;
				this.verticalCenter.value = (this.top.value + this.bottom.value) / 2;
				break;

			case 'x':
				this.element.css('left', value);
				this.left.value = value;
				this.right.value = value + this.width;
				this.horizontalCenter.value = (this.right.value + this.left.value) / 2;
				break;

			case 'y':
				this.element.css('top', value);
				this.top.value = value;
				this.bottom.value = value + this.height;
				this.verticalCenter.value = (this.top.value + this.bottom.value) / 2;
				break;

			case 'opacity': if (this.element) /*FIXME*/this.element.css('opacity', value); break;
			case 'visible':	if (this.element) /*FIXME*/this.element.css('visibility', value? 'visible': 'hidden'); break;
			case 'z':		this.element.css('z-index', value); break;
			case 'radius':	this.element.css('border-radius', value); break;
		}
		_globals.core.Object.prototype._update.apply(this, arguments);
	}

	_globals.core.Item.prototype.forceActiveFocus = function() {
		var item = this;
		while(item.parent) {
			item.parent._focusChild(item);
			item = item.parent;
		}
	}

	_globals.core.Item.prototype._focusTree = function(active) {
		this.activeFocus = active;
		if (this.focusedChild)
			this.focusedChild._focusTree(active);
	}

	_globals.core.Item.prototype._focusChild = function (child) {
		if (child.parent !== this)
			throw "invalid object passed as child";
		if (this.focusedChild)
			this.focusedChild._focusTree(false);
		this.focusedChild = child;
		if (this.focusedChild)
			this.focusedChild._focusTree(true);
	}

	_globals.core.Item.prototype._processKey = function (event) {
		if (this.focusedChild && this.focusedChild._processKey(event))
			return true;

		var key = keyCodes[event.which];
		if (key) {
			if (key in this._pressedHandlers) {
				var self = this;
				var handlers = this._pressedHandlers[key];
				for(var i = handlers.length - 1; i >= 0; --i) {
					var callback = handlers[i];
					if (callback(event))
						return true;
				}
			}
		}
		else {
			console.log("unhandled key", event.which);
		}
		return false;
	}

	_globals.core.MouseArea.prototype._onEnter = function() {
		if (!this.hoverEnabled)
			return;
		this.hovered = true;
		this._emitEvent('entered')
	}

	_globals.core.MouseArea.prototype._onExit = function() {
		if (!this.hoverEnabled)
			return;
		this.hovered = false;
		this._emitEvent('exited')
	}

	_globals.core.MouseArea.prototype._onClick = function() {
		this._emitEvent('clicked')
	}

	_globals.core.AnchorLine.prototype.toScreen = function() {
		var box = this.parent.parent? this.parent.parent.toScreen(): [0, 0];
		return box[this.boxIndex] + this.value;
	}

	_globals.core.Anchors.prototype._update = function(name) {
		var self = this.parent;
		var parent = self.parent;
		var anchors = this;

		var update_left = function() {
			var parent_box = parent.toScreen();
			var left = anchors.left.toScreen();
			var lm = anchors.leftMargin || anchors.margins;
			var rm = anchors.rightMargin || anchors.margins;
			self.x = left + lm - parent_box[0];
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
			self.x = right - parent_box[0] - rm - self.width;
		};

		var update_top = function() {
			var parent_box = parent.toScreen();
			var top = anchors.top.toScreen()
			var tm = anchors.topMargin || anchors.margins;
			var bm = anchors.bottomMargin || anchors.margins;
			self.y = top + tm - parent_box[1];
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
			self.y = bottom - parent_box[1] - bm - self.height;
		}

		var update_h_center = function() {
			var parent_box = parent.toScreen();
			var hcenter = anchors.horizontalCenter.toScreen();
			var lm = anchors.leftMargin || anchors.margins;
			var rm = anchors.rightMargin || anchors.margins;
			self.x = hcenter - self.width / 2 - parent_box[0] + lm - rm;
		}

		var update_v_center = function() {
			var parent_box = parent.toScreen();
			var vcenter = anchors.verticalCenter.toScreen();
			var tm = anchors.topMargin || anchors.margins;
			var bm = anchors.bottomMargin || anchors.margins;
			self.y = vcenter - self.height / 2 - parent_box[1] + tm - bm;
		}

		switch(name) {
			case 'left':
				update_left();
				anchors.left.onChanged('value', update_left);
				anchors.onChanged('leftMargin', update_left);
				break;

			case 'right':
				update_right();
				anchors.right.onChanged('value', update_right);
				anchors.onChanged('rightMargin', update_right);
				break;

			case 'top':
				update_top();
				anchors.top.onChanged('value', update_top);
				anchors.onChanged('topMargin', update_top);
				break;

			case 'bottom':
				update_bottom();
				anchors.bottom.onChanged('value', update_bottom);
				anchors.onChanged('bottomMargin', update_bottom);
				break;

			case 'horizontalCenter':
				update_h_center();
				self.onChanged('width', update_h_center);
				anchors.onChanged('leftMargin', update_h_center);
				anchors.onChanged('rightMargin', update_h_center);
				anchors.horizontalCenter.onChanged('value', update_h_center);
				break;

			case 'verticalCenter':
				update_v_center();
				self.onChanged('height', update_v_center);
				anchors.onChanged('topMargin', update_v_center);
				anchors.onChanged('bottomMargin', update_v_center);
				anchors.verticalCenter.onChanged('value', update_v_center);
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
			case 'pointSize': this.parent.element.css('font-size', value + "pt"); break;
			case 'pixelSize': this.parent.element.css('font-size', value + "px"); break;
			case 'italic': this.parent.element.css('font-style', value? 'italic': 'normal'); break;
		}
		_globals.core.Object.prototype._update.apply(this, arguments);
	}

	_globals.core.Text.prototype._update = function(name, value) {
		switch(name) {
			case 'text': this.element.text(value); this.paintedWidth = this.element.width(); this.paintedHeight = this.element.height(); break;
			case 'color': this.element.css('color', value); break;
		}
		_globals.core.Item.prototype._update.apply(this, arguments);
	}

	_globals.core.Rectangle.prototype._update = function(name, value) {
		switch(name) {
			case 'color': this.element.css('background-color', value); break;
		}
		_globals.core.Item.prototype._update.apply(this, arguments);
	}

	_globals.core.Image.prototype.Null = 0;
	_globals.core.Image.prototype.Ready = 1;
	_globals.core.Image.prototype.Loading = 2;
	_globals.core.Image.prototype.Error = 3;

	_globals.core.Image.prototype._onLoad = function() {
		this.paintedWidth = this.element.get(0).naturalWidth;
		this.paintedHeight = this.element.get(0).naturalHeight;
		this.status = this.Ready;
	}

	_globals.core.Image.prototype._onError = function() {
		this.status = this.Error;
	}

	_globals.core.Image.prototype._update = function(name, value) {
		switch(name) {
			case 'source': this.status = value? this.Loading: this.Null; this.element.attr('src', value); break;
		}
		_globals.core.Item.prototype._update.apply(this, arguments);
	}

	exports.Context.prototype = Object.create(qml.core.Item.prototype);
	exports.Context.prototype.constructor = exports.Context;

	exports.Context.prototype._onCompleted = function(callback) {
		this._completedHandlers.push(callback);
	}

	exports.Context.prototype._completed = function() {
		this._completedHandlers.forEach(function(callback) { try { callback(); } catch(ex) { console.log("completed handler failed", ex); }} )
		this._completedHandlers = [];
	}

	exports.Context.prototype.start = function(name) {
		var proto;
		if (typeof name == 'string') {
			//console.log('creating component...', name);
			var path = name.split('.');
			proto = _globals;
			for (var i = 0; i < path.length; ++i)
				proto = proto[path[i]]
		}
		else
			proto = name;
		var instance = Object.create(proto.prototype);
		proto.apply(instance, [this]);
		this._completed();
		return instance;
	}
}

exports.Context = function() {
	_globals.core.Item.apply(this, null);

	this._local['renderer'] = this;
	this._completedHandlers = []

	var win = $(window);
	var w = win.width();
	var h = win.height();
	//console.log("window size: " + w + "x" + h);

	var body = $('body');
	var div = $("<div id='renderer'></div>");
	body.append(div);
	$('head').append($("<style>" +
		"div#renderer { position: absolute; left: 0px; top: 0px; } " +
		"div { position: absolute; border-style: solid; border-width: 0px; white-space: nowrap; } " +
		"img { position: absolute; } " +
		"</style>"
	));

	this.element = div
	this.width = w;
	this.height = h;

	win.on('resize', function() { this.width = win.width(); this.height = win.height(); }.bind(this));
	var self = this;
	$(document).keydown(function(event) { self._processKey(event); } );

	//console.log("context created");
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
		default: if (type[0].toUpperCase() == type[0]) value = null; break;
	}
	Object.defineProperty(self, name, {
		get: function() {
			return value;
		},
		set: function(newValue) {
			if (!self.getAnimation) {
				console.log("bound unknown object", self)
				throw "invalid object";
			}
			var animation = self.getAnimation(name)
			if (animation && value != newValue) {
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

					interpolated_value = animation.interpolate(dst, src, t);
					self._update(name, interpolated_value, src);
				});

				timeout = setTimeout(function() {
					clearInterval(timer);
					interpolated_value = undefined;
					self._update(name, dst, src);
				}, duration);
			}
			oldValue = value;
			if (oldValue != newValue) {
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

exports._bootstrap = function(self, name) {
	switch(name) {
		case 'core.ListModel':
			self._rows = []
			break;
		case 'core.Item':
			if (!self.parent) //top-level item, do not create item
				break;
			if (self.element)
				throw "double ctor call";
			self.element = $('<div/>');
			self.parent.element.append(self.element);
			break;
		case 'core.MouseArea':
			self.element.hover(self._onEnter.bind(self), self._onExit.bind(self));
			self.element.on('click', self._onClick.bind(self));
			break;
		case 'core.Image':
			self.element.remove();
			self.element = $('<img/>');
			self.parent.element.append(self.element);
			self.element.on('load', self._onLoad.bind(self));
			self.element.on('error', self._onError.bind(self));
			break;
	}
}

