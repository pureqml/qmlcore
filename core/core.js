/* qml.core javascript code */

if (!_globals.core)
	_globals.core = {}

_globals.core.Object = function() {}
_globals.core.Object.prototype._update = function(name, value) {}
_globals.core.Object.prototype._ctor = function(parent) { this.parent = parent; }


function setup(context) {
	_globals.core.Item.prototype.children = []

	_globals.core.Border.prototype._updateBox = function() {
		var width = this.width;
		var parent = this.parent;
		var x = parent.x;
		var y = parent.y;
		var el = parent.element;
		el.css('border-width', width);
		el.css('left', x - width);
		el.css('top', y + width);
	}

	_globals.core.Border.prototype._update = function(name, value) {
		switch(name) {
			case 'width': this._updateBox(); return;
			case 'color': this.parent.element.css('border-color', value); return;
		}
	}

	_globals.core.Item.prototype._ctor = function(parent) {
		_globals.core.Object.prototype._ctor.apply(this, arguments);
		this.element = $('<div/>');
		parent.element.append(this.element);
	}

	_globals.core.Item.prototype._update = function(name, value) {
		switch(name) {
			case 'width':
				this.element.css('width', value);
				return;
			case 'height':
				this.element.css('height', value);
				return;
			case 'x':
				this.element.css('left', value);
				if (this.border)
					this.border._updateBox();
				return;
			case 'y':
				this.element.css('top', value);
				if (this.border)
					this.border._updateBox();
				return;
			case 'border':
				if (this.border)
					this.border._updateBox();
				return;
			case 'radius':
				this.element.css('border-radius', value);
				return;
		}
		_globals.core.Object.prototype._update.apply(this, arguments);
	}

	_globals.core.Rectangle.prototype._update = function(name, value) {
		switch(name) {
			case 'color': this.element.css('background-color', value); return;
		}
		_globals.core.Item.prototype._update.apply(this, arguments);
	}
}

exports.Context = function() {
	var windowW = $(window).width();
	var windowH = $(window).height();
	console.log("window size: " + windowW + "x" + windowH);
	var body = $('body');
	var div = $("<div id='renderer'></div>");
	body.append(div)
	this.element = div
	this.element.css({width: windowW, height: windowH});
	console.log("context created");

	setup(this);
}

exports.Context.prototype.start = function(name) {
	console.log('creating component...', name);
	var path = name.split('.');
	var proto = _globals;
	for (var i = 0; i < path.length; ++i)
		proto = proto[path[i]]
	console.log(proto);
	var instance = Object.create(proto.prototype);
	proto.apply(instance, [this]);
	return instance;
}

exports.addProperty = function(self, type, name) {
	var value;
	switch(type) {
		case 'int':			value = 0;
		case 'bool':		value = false;
		case 'real':		value = 0.0;
		default: if (type[0].toUpperCase() == type[0]) value = null;
	}
	Object.defineProperty(self, name, {
		get: function() {
			return value;
		},
		set: function(newValue) {
			oldValue = value;
			value = newValue;
			self._update(name, newValue, oldValue);
		}
	});
}

