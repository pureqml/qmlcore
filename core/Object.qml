///the most basic QML Object, generic event emitter, properties and id links holder
EventEmitter {
	///@private
	constructor: {
		this.parent = parent
		this.children = []

		this._context = parent? parent._context: null
		if (_delegate === true)
			this._local['_delegate'] = this
		this._changedHandlers = {}
		this._changedConnections = []
		this._pressedHandlers = {}
		this._animations = {}
		this._updaters = {}
	}

	/// discard object
	function discard() {
		this._changedConnections.forEach(function(connection) {
			connection[0].removeOnChanged(connection[1], connection[2])
		})
		this._changedConnections = []

		this.children.forEach(function(child) { child.discard() })
		this.children = []

		this.parent = null
		this._local = {}
		this._changedHandlers = {}
		this._pressedHandlers = {}
		this._animations = {}
		//for(var name in this._updaters) //fixme: it was added once, then removed, is it needed at all? it double-deletes callbacks
		//	this._replaceUpdater(name)
		this._updaters = {}

		_globals.core.EventEmitter.prototype.discard.apply(this)
	}

	/**@param child:Object object to add
	adds child object to children*/
	function addChild(child) {
		this.children.push(child);
	}

	/// @private sets id
	function _setId(name) {
		var p = this;
		while(p) {
			p._local[name] = this;
			p = p.parent;
		}
	}

	///@private register callback on property's value changed
	function onChanged(name, callback) {
		var storage = this._changedHandlers
		var handlers = storage[name]
		if (handlers !== undefined)
			handlers.push(callback);
		else
			storage[name] = [callback];
	}

	///@private
	function connectOnChanged(target, name, callback) {
		target.onChanged(name, callback)
		this._changedConnections.push([target, name, callback])
	}

	///@private removes 'on changed' callback
	function removeOnChanged(name, callback) {
		if (name in this._changedHandlers) {
			var handlers = this._changedHandlers[name];
			var idx = handlers.indexOf(callback)
			if (idx >= 0)
				handlers.splice(idx, 1)
			else if (_globals.core.trace.listeners)
				log('failed to remove changed listener for', name, 'from', this)
		}
	}

	/// @private removes dynamic value updater
	function _replaceUpdater (name, newUpdaters) {
		var updaters = this._updaters
		var oldUpdaters = updaters[name]
		if (oldUpdaters !== undefined) {
			oldUpdaters.forEach(function(data) {
				var object = data[0]
				var name = data[1]
				var callback = data[2]
				object.removeOnChanged(name, callback)
			})
		}

		if (newUpdaters)
			updaters[name] = newUpdaters
		else
			delete updaters[name]
	}

	///@private registers key handler
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

	///@private
	function _update (name, value) {
		var protoCallbacks = this['__changed__' + name]
		var handlers = this._changedHandlers[name]

		var hasProtoCallbacks = protoCallbacks !== undefined
		var hasHandlers = handlers !== undefined

		if (!hasProtoCallbacks && !hasHandlers)
			return

		var invoker = _globals.core.safeCall(this, [value], function(ex) { log("on " + name + " changed callback failed: ", ex, ex.stack) })

		if (hasProtoCallbacks)
			protoCallbacks.forEach(invoker)

		if (hasHandlers)
			handlers.forEach(invoker)
	}

	///@private patch property storage directly without signalling. You normally don't need it
	function _setProperty(name, value) {
		var animation = this._animations[name]
		if (animation !== undefined)
			animation.disable()

		//cancel any running software animations
		var storageName = '__property_' + name
		var storage = this[storageName] || {}
		delete storage.interpolatedValue
		storage.value = value
		this[storageName] = storage

		if (animation !== undefined)
			animation.enable()
	}

	///@private updates animation properties on given property
	function updateAnimation (name, animation) {
		this._context.backend.setAnimation(this, name, animation)
	}

	///@private sets animation on given property
	function setAnimation (name, animation) {
		var context = this._context
		var backend = context.backend
		if (name === 'contentX' || name === 'contentY')
			log('WARNING: you\'re trying to animate contentX/contentY property, this will always use animation frames, ignoring CSS transitions, please use content.x/content.y instead')

		var component = this
		animation._target = component
		animation._property = name
		context.scheduleAction(function() {
			component._animations[name] = animation
			if (backend.setAnimation(component, name, animation))
				animation._native = true
		}, 1)
	}

	///@private gets animation on given property
	function getAnimation (name, animation) {
		if (!this._context._completed)
			return null
		var a = this._animations[name]
		return (a !== undefined && a.enabled() && !a._native)? a:  null;
	}

	///@private called to test if the component can have focus, generic object cannot be focused, so return false, override it to implement default focus policy
	function _tryFocus () { return false }
}
