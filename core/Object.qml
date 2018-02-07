///the most basic QML Object, generic event emitter, properties and id links holder
EventEmitter {
	constructor: {
		this.parent = parent
		this.children = []
		this.__properties = {}

		this._context = parent? parent._context: null
		if (row) {
			var local = this._local
			local.model = row
			local._delegate = this
		}
		this._changedConnections = []
		this._pressedHandlers = {}
		this._properties = {}
	}

	prototypeConstructor: {
		ObjectPrototype._propertyToStyle = {
			width: 'width', height: 'height',
			x: 'left', y: 'top', viewX: 'left', viewY: 'top',
			opacity: 'opacity',
			border: 'border',
			radius: 'border-radius',
			rotate: 'transform',
			boxshadow: 'box-shadow',
			transform: 'transform',
			visible: 'visibility', visibleInView: 'visibility',
			background: 'background',
			color: 'color',
			backgroundImage: 'background-image',
			font: 'font'
		}
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
		this._pressedHandlers = {}

		var properties = this.__properties
		for(var name in properties) //fixme: it was added once, then removed, is it needed at all? it double-deletes callbacks
			properties[name].discard()
		this._properties = {}

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
		var storage = this._createPropertyStorage(name)
		storage.onChanged.push(callback)
	}

	///@private
	function connectOnChanged(target, name, callback) {
		target.onChanged(name, callback)
		this._changedConnections.push([target, name, callback])
	}

	///@private removes 'on changed' callback
	function removeOnChanged(name, callback) {
		var storage = this.__properties[name]
		if (storage !== undefined) {
			var handlers = storage.onChanged
			var idx = handlers.indexOf(callback)
			if (idx >= 0)
				handlers.splice(idx, 1)
			else if ($manifest$trace$listeners)
				log('failed to remove changed listener for', name, 'from', this)
		}
	}

	/// @private removes dynamic value updater
	function _removeUpdater (name) {
		var storage = this.__properties[name]
		if (storage !== undefined)
			storage.removeUpdater()
	}

	/// @private replaces dynamic value updater
	function _replaceUpdater (name, newUpdaters) {
		this._createPropertyStorage(name).replaceUpdater(this, newUpdaters)
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

	///@private creates property storage
	function _createPropertyStorage(name, value) {
		var storage = this.__properties[name]
		if (storage !== undefined)
			return storage

		return this.__properties[name] = new _globals.core.core.PropertyStorage(value)
	}

	///mixin api: set default forwarding _target
	function setPropertyForwardingTarget(name, target) {
		this._createPropertyStorage(name).forwardTarget = target
	}

	///@private patch property storage directly without signalling.
	function _setProperty(name, value) {
		//cancel any running software animations
		var storage = this._createPropertyStorage(name, value)
		var animation = storage.animation
		if (animation !== undefined)
			animation.disable()
		storage.setCurrentValue(this, null, value)
		if (animation !== undefined)
			animation.enable()
	}

	///@private updates animation properties on given property
	function updateAnimation (name, animation) {
		this._context.backend.setAnimation(this, name, animation)
	}

	///@private sets animation on given property
	function setAnimation (name, animation) {
		if ($manifest$disableAnimations)
			return

		var context = this._context
		var backend = context.backend
		if (name === 'contentX' || name === 'contentY')
			log('WARNING: you\'re trying to animate contentX/contentY property, this will always use animation frames, ignoring CSS transitions, please use content.x/content.y instead')

		animation._target = this
		animation._property = name
		var storage = this._createPropertyStorage(name)
		storage.animation = animation
		if (backend.setAnimation(this, name, animation))
			animation._native = true
	}

	///@private called to test if the component can have focus, generic object cannot be focused, so return false, override it to implement default focus policy
	function _tryFocus () { return false }
}
