///the most basic QML Object, generic event emitter, properties and id links holder
EventEmitter {
	constructor: {
		exports.core.EventEmitter.apply(this)

		this.parent = parent
		this.children = []

		this._context = parent? parent._context: null
		this._local = {}
		if (_delegate === true)
			this._local._delegate = this
		this._changedHandlers = {}
		this._changedConnections = []
		this._pressedHandlers = {}
		this._animations = {}
		this._updaters = {}
	}

	function discard() {
		this._changedConnections.forEach(function(connection) {
			connection[0].removeOnChanged(connection[1], connection[2])
		})
		this._changedConnections = []

		this.children.forEach(function(child) { child.discard() })
		this.children = []

		this.parent = null
		this._context = null
		this._local = {}
		this._changedHandlers = {}
		this._pressedHandlers = {}
		this._animations = {}

		_globals.core.EventEmitter.prototype.discard.apply(this)
	}

	///adds child object to children
	function addChild(child) {
		this.children.push(child);
	}

	/// @internal sets id
	function _setId(name) {
		var p = this;
		while(p) {
			p._local[name] = this;
			p = p.parent;
		}
	}

	/// register callback on property's value changed
	function onChanged(name, callback) {
		if (name in this._changedHandlers)
			this._changedHandlers[name].push(callback);
		else
			this._changedHandlers[name] = [callback];
	}

	function connectOnChanged(target, name, callback) {
		target.onChanged(name, callback)
		this._changedConnections.push([target, name, callback])
	}

	/// removes 'on changed' callback
	function removeOnChanged(name, callback) {
		if (name in this._changedHandlers) {
			var handlers = this._changedHandlers[name];
			var idx = handlers.indexOf(callback)
			if (idx >= 0)
				handlers.splice(idx, 1)
			else
				log('failed to remove changed listener for', name, 'from', this)
		}
	}

	/// @internal removes dynamic value updater
	function _removeUpdater (name, callback) {
		if (name in this._updaters)
			this._updaters[name]();

		if (callback) {
			this._updaters[name] = callback;
		} else
			delete this._updaters[name]
	}

	/// registers key handler
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

	/// gets object by id
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

	/// sets animation on given property
	function setAnimation (name, animation) {
		this._animations[name] = animation;
	}

	/// gets animation on given property
	function getAnimation (name, animation) {
		var a = this._animations[name]
		return (a && a.enabled())? a: null;
	}

	/// called to test if the component can have focus, generic object cannot be focused, so return false, override it to implement default focus policy
	function _tryFocus () { return false }
}
