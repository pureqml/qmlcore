/* qml.core javascript code */

if (!_globals.core)
	_globals.core = {}

_globals.core.Object = function(parent) {
	this.parent = parent;
	this._local = {}
	this._changedHandlers = {}
	this._eventHandlers = {}
	this._animations = {}
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

function setup(context) {
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

		console.log("starting timer", this.interval, this.repeat);
		var self = this;
		if (this.repeat)
			this._interval = setInterval(function() { self._emitEvent('triggered'); }, this.interval);
		else
			this._timeout = setTimeout(function() { self._emitEvent('triggered'); }, this.interval);
	}

	_globals.core.Timer.prototype._update = function(name, value) {
		switch(name) {
			case 'running': this._restart(); break;
			case 'interval': this._restart(); break;
			case 'repeat': this._restart(); break;
		}
		_globals.core.Object.prototype._update.apply(this, arguments);
	}

	_globals.core.Item.prototype.children = []

	_globals.core.Item.prototype.toScreen = function() {
		var item = this;
		var x = 0, y = 0;
		while(item) {
			x += item.x;
			y += item.y;
			item = item.parent;
		}
		return [x, y, x + this.width, y + this.height];
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
			case 'width': 	this.element.css('width', value); this.right.value = this.x + value; break;
			case 'height':	this.element.css('height', value); this.bottom.value = this.y + value; break;
			case 'x':		this.element.css('left', value); this.left.value = value; this.right.value = value + this.width; break;
			case 'y':		this.element.css('top', value); this.top.value = value; this.bottom.value = value + this.height; break;
			case 'z':		this.element.css('z-index', value); break;
			case 'radius':	this.element.css('border-radius', value); break;
		}
		_globals.core.Object.prototype._update.apply(this, arguments);
	}

	_globals.core.AnchorLine.prototype.toScreen = function() {
		return this.parent.parent.toScreen()[this.boxIndex] + this.value;
	}

	_globals.core.Anchors.prototype._update = function(name, line) {
		var self = this.parent;
		var target = line.parent;
		var anchors = this;
		var lm = anchors.leftMargin || anchors.margins;
		var rm = anchors.rightMargin || anchors.margins;
		var tm = anchors.topMargin || anchors.margins;
		var bm = anchors.bottomMargin || anchors.margins;

		var update_left = function() {
			var parent_box = self.parent.toScreen();
			//console.log(target_box, parent_box);
			self.x = line.toScreen() + lm - parent_box[0];
			if (anchors.right) {
				var right_target_box = anchors.right.parent.toScreen();
				self.width = (right_target_box[2] - parent_box[0]) - self.x - rm ;
			}
		};

		var update_right = function() {
			var parent_box = self.parent.toScreen();
			//console.log(target_box, parent_box);
			if (anchors.left) {
				var left_target_box = anchors.left.parent.toScreen();
				self.width = line.toScreen() - left_target_box[0] - lm - rm;
			}
			self.x = (line.toScreen() - parent_box[0] - self.width) + lm;
		};

		var update_top = function() {
			var parent_box = self.parent.toScreen();
			//console.log(target_box, parent_box);
			self.y = line.toScreen() + tm - parent_box[1];
			if (anchors.bottom) {
				var bottom_target_box = anchors.bottom.parent.toScreen();
				self.height = (bottom_target_box[3] - parent_box[1]) - self.y - bm;
			}
		};

		var update_bottom = function() {
			var parent_box = self.parent.toScreen();
			//console.log(target_box, parent_box);
			if (anchors.top) {
				var top_target_box = anchors.top.parent.toScreen();
				self.height = line.toScreen() - top_target_box[1] - tm - bm;
			}
			self.y = (line.toScreen() - parent_box[1] - self.height) + tm;
		};

		switch(name) {
			case 'left':
				update_left();
				target.left.onChanged('value', update_left);
				break;

			case 'right':
				update_right();
				target.right.onChanged('value', update_right);
				break;

			case 'top':
				update_top();
				target.top.onChanged('value', update_top);
				break;

			case 'bottom':
				update_bottom();
				target.bottom.onChanged('value', update_bottom);
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
			case 'text': this.element.text(value); break;
		}
		_globals.core.Item.prototype._update.apply(this, arguments);
	}

	_globals.core.Rectangle.prototype._update = function(name, value) {
		switch(name) {
			case 'color': this.element.css('background-color', value); break;
		}
		_globals.core.Item.prototype._update.apply(this, arguments);
	}
}

exports.Context = function() {
	_globals.core.Object.apply(this, null);

	var w = $(window).width();
	var h = $(window).height();
	console.log("window size: " + w + "x" + h);

	var body = $('body');
	var div = $("<div id='renderer'></div>");
	body.append(div);
	$('head').append($("<style>" +
		"div#renderer { position: absolute; left: 0px; top: 0px; } " +
		"div { position: absolute; border-style: solid; border-width: 0px; white-space: nowrap; } " +
		"</style>"
	));

	exports.addProperty(this, 'int', 'x');
	exports.addProperty(this, 'int', 'y');
	exports.addProperty(this, 'int', 'width');
	exports.addProperty(this, 'int', 'height');

	this.element = div
	this.element.css({width: w, height: h});
	this.width = w;
	this.height = h;

	console.log("context created");
	setup(this);
}

exports.Context.prototype = Object.create(_globals.core.Object.prototype);
exports.Context.prototype.constructor = exports.Context;

exports.Context.prototype.toScreen = function() {
	return [0, 0, this.width, this.height];
}

exports.Context.prototype.start = function(name) {
	var proto;
	if (typeof name == 'string') {
		console.log('creating component...', name);
		var path = name.split('.');
		proto = _globals;
		for (var i = 0; i < path.length; ++i)
			proto = proto[path[i]]
	}
	else
		proto = name;
	var instance = Object.create(proto.prototype);
	proto.apply(instance, [this]);
	return instance;
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

					interpolated_value = t * (dst - src) + src;
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

exports._bootstrap = function(self, name) {
	switch(name) {
		case 'core.Item':
			if (self.element)
				throw "double ctor call";
			self.element = $('<div/>');
			self.parent.element.append(self.element);
			break;
	}
}
