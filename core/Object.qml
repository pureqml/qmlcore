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
			local.modelData = row
			local._delegate = this
		}
		this._changedConnections = []
		this._properties = {}
	}

	function completed() {
		this._context.__completed(this)
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

	/**@param child:Object object to remove
	removes child object from children*/
	function removeChild(child) {
		var children = this.children
		var idx = children.indexOf(child)
		if (idx >= 0)
			children.splice(idx, 1)
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
	function onChanged(name, callback, skip) {
		var storage = this._createPropertyStorage(name)
		storage.onChanged.push(callback)
		if (!skip)
			storage.callOnChangedWithCurrentValue(this, name, callback)
	}

	///@private
	function connectOnChanged(target, name, callback, skip) {
		if (!target || !('onChanged' in target)) //could be plain js object, can't connect
			return false
		target.onChanged(name, callback, true)
		this._changedConnections.push(target, name, callback)
		if (!skip)
		{
			var storage = target._createPropertyStorage(name)
			storage.callOnChangedWithCurrentValue(target, name, callback)
		}
		return true
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

	///@private gets property storage
	function _getPropertyStorage(name) {
		return this.__properties[name]
	}

	///@private creates property storage
	function _createPropertyStorage(name, value) {
		var storage = this.__properties[name]
		if (storage !== undefined)
			return storage

		return this.__properties[name] = new $core.core.PropertyStorage(value)
	}

	///@internal update property storage directly without animation and with or without signalling.
	function _setProperty(name, value, callUpdate) {
		//cancel any running software animations
		var storage = this._createPropertyStorage(name, value)
		var animation = storage.animation
		if (animation !== undefined)
			animation.disable()
		storage.setCurrentValue(this, name, value, callUpdate)
		if (animation !== undefined)
			animation.enable()
	}

	///updates animation properties on given property
	function updateAnimation (name, animation) {
		this._context.backend.setAnimation(this, name, animation)
	}

	///gets animation on given property
	function getAnimation (name) {
		var storage = this.__properties[name]
		return storage? storage.animation: null
	}

	///sets animation on given property
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
		if (backend.setAnimation(this, name, animation)) {
			animation._native = true
		} else {
			var target = this[name]
			//this is special fallback for combined css animation, e.g transform
			//if native backend refuse to animate, we call _animateAll()
			//see Transform._animateAll for details
			if (target && (typeof target === 'object') && ('_animateAll' in target)) {
				target._animateAll(animation)
			}
		}
	}

	/// resets current animation if any
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

	/// stops event propagation
	function stopEvent(event) {
		$core.callMethod(event, 'preventDefault')
		$core.callMethod(event, 'stopImmediatePropagation')
	}

	///@private called to test if the component can have focus, generic object cannot be focused, so return false, override it to implement default focus policy
	function _tryFocus () { return false }

	function tr() {
		var context = this._context
		return context.tr.apply(context, arguments)
	}

	function qsTr() {
		var context = this._context
		return context.tr.apply(context, arguments)
	}
}
