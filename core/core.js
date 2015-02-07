/* qml.core javascript code */

if (!_globals.core)
	_globals.core = {}

_globals.core.Object = function(parent) {
	this.parent = parent;
	this._local = {}
	this._changedHandlers = {}
}

_globals.core.Object.prototype._update = function(name, value) {
	if (name in this._changedHandlers) {
		var handlers = this._changedHandlers[name];
		handlers.forEach(function(callback) { callback(value); });
	}
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

_globals.core.Object.prototype.get = function (name) {
	if (name in this._local)
		return this._local[name];
	if (this.hasOwnProperty(name))
		return this[name];
	console.log(name, this);
	throw ("invalid property requested: '" + name + "' in context of " + this);
}


function setup(context) {
	_globals.core.Item.prototype.children = []

	_globals.core.Item.prototype.toScreen = function() {
		var item = this;
		var x = 0, y = 0;
		while(item) {
			console.log(item, item.x, item.y, x, y);
			x += item.x;
			y += item.y;
			item = item.parent;
		}
		return [x, y, x + this.width, y + this.height];
	}

	_globals.core.Border.prototype._update = function(name, value) {
		switch(name) {
			case 'width': this.parent.element.css('border-width', value); break;
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
			case 'radius':	this.element.css('border-radius', value); break;
		}
		_globals.core.Object.prototype._update.apply(this, arguments);
	}

	_globals.core.AnchorLine.prototype._update = function(name, value) {
		_globals.core.Object.prototype._update.apply(this, arguments);
	}

	_globals.core.Anchors.prototype._update = function(name, line) {
		var self = this.parent;
		var target = line.parent;
		var anchors = this;
		var lm = anchors.leftMargin || anchors.margins;
		var rm = anchors.rightMargin || anchors.margins;

		var update_left = function() {
			console.log("left.changed");
			var target_box = target.toScreen();
			var parent_box = self.parent.toScreen();
			console.log(target_box, parent_box);
		};

		var update_right = function() {
			console.log("right.changed");
		};

		switch(name) {
			case 'left':
				update_left(target.left.value);
				target.left.onChanged('value', update_left);
				break;

			case 'right':
				update_right(target.right.value);
				target.right.onChanged('value', update_left);
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
	body.append(div)

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
			oldValue = value;
			if (oldValue != newValue) {
				value = newValue;
				self._update(name, newValue, oldValue);
			}
		}
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
