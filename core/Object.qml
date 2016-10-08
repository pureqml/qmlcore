EventEmitter {
	constructor: {
		exports.core.EventEmitter.apply(this)

		this.parent = parent
		this.children = []

		this._context = parent? parent._context: null
		this._local = {}
		this._changedHandlers = {}
		this._pressedHandlers = {}
		this._animations = {}
		this._updaters = {}
	}

	function addChild(child) {
		this.children.push(child);
	}

	function _setId(name) {
		var p = this;
		while(p) {
			p._local[name] = this;
			p = p.parent;
		}
	}

	function onChanged(name, callback) {
		if (name in this._changedHandlers)
			this._changedHandlers[name].push(callback);
		else
			this._changedHandlers[name] = [callback];
	}

	function removeOnChanged(name, callback) {
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

	function _removeUpdater (name, callback) {
		if (name in this._updaters)
			this._updaters[name]();

		if (callback) {
			this._updaters[name] = callback;
		} else
			delete this._updaters[name]
	}

	function onPressed (name, callback) {
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

	function _update (name, value) {
		if (name in this._changedHandlers) {
			var handlers = this._changedHandlers[name]
			var invoker = exports.core.safeCall([value], function(ex) { log("on " + name + " changed callback failed: ", ex, ex.stack) })
			handlers.forEach(invoker)
		}
	}

	function _get (name) {
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

	function setAnimation (name, animation) {
		this._animations[name] = animation;
	}

	function getAnimation (name, animation) {
		var a = this._animations[name]
		return (a && a.enabled())? a: null;
	}

	function _tryFocus () { return false }
}
