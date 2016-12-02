CoreObject {
	constructor: {
		this._eventHandlers = {}
		this._onFirstListener = {}
		this._onLastListener = {}
		this._onConnections = []
	}

	function discard() {
		for(var name in this._eventHandlers)
			this.removeAllListeners(name)
		this._onFirstListener = {}
		this._onLastListener = {}
		this._onConnections.forEach(function(connection) {
			connection[0].removeListener(connection[1], connection[2])
		})
		this._onConnections = []
	}

	function on (name, callback) {
		if (name in this._eventHandlers)
			this._eventHandlers[name].push(callback)
		else {
			if (name in this._onFirstListener) {
				//log('first listener to', name)
				this._onFirstListener[name](name)
			} else if ('' in this._onFirstListener) {
				//log('first listener to', name)
				this._onFirstListener[''](name)
			}
			if (this._eventHandlers[name])
				throw new Error('listener callback added event handler')
			this._eventHandlers[name] = [callback]
		}
	}

	function connectOn(target, name, callback) {
		target.on(name, callback)
		this._onConnections.push([target, name, callback])
	}

	function onListener (name, first, last) {
		this._onFirstListener[name] = first
		this._onLastListener[name] = last
	}

	function emit (name) {
		var invoker = _globals.core.safeCall(
			_globals.core.copyArguments(arguments, 1),
			function(ex) { log("event/signal " + name + " handler failed:", ex, ex.stack) }
		)

		if (name in this._eventHandlers) {
			var handlers = this._eventHandlers[name]
			handlers.forEach(invoker)
		}
	}

	function removeAllListeners(name) {
		delete this._eventHandlers[name]
		if (name in this._onLastListener)
			this._onLastListener[name](name)
		else if ('' in this._onLastListener) {
			//log('first listener to', name)
			this._onLastListener[''](name)
		}
	}

	function removeListener (name, callback) {
		if (!(name in this._eventHandlers) || callback === undefined || callback === null) {
			log('invalid removeListener(' + name + ', ' + callback + ') invocation', new Error().stack)
			return
		}

		var handlers = this._eventHandlers[name]
		var idx = handlers.indexOf(callback)
		if (idx >= 0)
			handlers.splice(idx, 1)
		else
			log('failed to remove listener for', name, 'from', this)

		if (!handlers.length)
			this.removeAllListeners(name)
	}

}
