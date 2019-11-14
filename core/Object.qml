///the most basic QML Object, generic event emitter, properties and id links holder
EventEmitter {
	constructor: {
		this.parent = parent
		this.children = []
		this.__properties = {}
		this.__attachedObjects = []
		if (parent)
			parent.__attachedObjects.push(this)

		var context = this._context = parent? parent._context: null
		if (row) {
			var local = this._local
			local.model = row
			local._delegate = this
		}
		this._changedConnections = []
		this._properties = {}
	}

	function completed() {
		if (this.__complete !== $core.CoreObject.prototype.__complete && this._registerDelayedAction('complete'))
			this._context.__onCompleted(this)
	}

	/// @private
	function _registerDelayedAction(name) {
		var registry = this._registeredDelayedActions

		if (registry === undefined)
			registry = this._registeredDelayedActions = {}

		if (registry[name] === true)
			return false

		registry[name] = true
		return true
	}

	/// @private
	function _cancelDelayedAction(name) {
		this._registeredDelayedActions[name] = false
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

	/// @private removes all on changes connections
	function removeAllOnChanged() {
		var connections = this._changedConnections
		for(var i = 0, n = connections.length; i < n; i += 3)
			connections[i].removeOnChanged(connections[i + 1], connections[i + 2])
		this._changedConnections = []
	}

	/// discard object
	function discard() {
		this.removeAllOnChanged()

		var attached = this.__attachedObjects
		this.__attachedObjects = []
		attached.forEach(function(child) { child.discard() })

		var parent = this.parent
		if (parent) {
			var discardIdx = parent.__attachedObjects.indexOf(this)
			if (discardIdx >= 0)
				parent.__attachedObjects.splice(discardIdx, 1)
		}

		this.children = []

		this.parent = null
		this._local = {}

		var properties = this.__properties
		for(var name in properties) //fixme: it was added once, then removed, is it needed at all? it double-deletes callbacks
			properties[name].discard()
		this._properties = {}

		$core.EventEmitter.prototype.discard.apply(this)
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
		this._changedConnections.push(target, name, callback)
	}

	///@private removes 'on changed' callback
	function removeOnChanged(name, callback) {
		var storage = this.__properties[name]
		var removed
		if (storage !== undefined)
			removed = storage.removeOnChanged(callback)

		if ($manifest$trace$listeners && !removed)
			log('failed to remove changed listener for', name, 'from', this)
	}

	/// @private removes dynamic value updater
	function _removeUpdater (name) {
		var storage = this.__properties[name]
		if (storage !== undefined)
			storage.removeUpdater()
	}

	/// @private replaces dynamic value updater
	function _replaceUpdater (name, callback, deps) {
		this._createPropertyStorage(name).replaceUpdater(this, callback, deps)
	}

	///@private creates property storage
	function _createPropertyStorage(name, value) {
		var storage = this.__properties[name]
		if (storage !== undefined)
			return storage

		return this.__properties[name] = new $core.core.PropertyStorage(value)
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

		if (animation === null)
			return this.resetAnimation(name)

		var context = this._context
		var backend = context.backend
		if (name === 'contentX' || name === 'contentY')
			log('WARNING: you\'re trying to animate contentX/contentY property, this will always use animation frames, ignoring CSS transitions, please use content.x/content.y instead')

		animation.target = this
		animation.property = name
		var storage = this._createPropertyStorage(name)
		storage.animation = animation
		if (backend.setAnimation(this, name, animation))
			animation._native = true
	}

	function resetAnimation(name) {
		var storage = this.__properties[name]
		if (storage !== undefined && storage.animation) {
			var animation = storage.animation
			animation.disable()
			var target = animation.target
			animation.target = target
			storage.animation = null
			animation.enable() //fixme: enabling without target to avoid installing native animation
			animation.target = target
		}
	}

	/// outputs component path in qml (e.g Rectangle → Item → ListItem → Rectangle)
	function getComponentPath() {
		var path = []
		var self = this
		while(self) {
			var name = self.componentName
			if (self.parent) {
				var idx = self.parent.children.indexOf(self)
				if (idx >= 0)
					name += '@' + idx
			}
			path.unshift(name)
			self = self.parent
		}
		return path.join(" → ")
	}

	///@private called to test if the component can have focus, generic object cannot be focused, so return false, override it to implement default focus policy
	function _tryFocus () { return false }
}
