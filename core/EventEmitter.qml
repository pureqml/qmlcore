CoreObject {
	constructor: {
		this._eventHandlers = {}
		this._onFirstListener = {}
		this._onLastListener = {}
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
			this._eventHandlers[name] = [callback]
		}
	}

	function onListener (name, first, last) {
		this._onFirstListener[name] = first
		this._onLastListener[name] = last
	}

	function emit (name) {
		var args = _globals.core.copyArguments(arguments, 1)
		var invoker = exports.core.safeCall(args, function(ex) { log("event/signal " + name + " handler failed:", ex, ex.stack) })
		if (name in this._eventHandlers) {
			var handlers = this._eventHandlers[name]
			handlers.forEach(invoker)
		}
	}

	function removeListener (name, callback) {
		if (!(name in this._eventHandlers) || callback === undefined || callback === null)
			return

		var handlers = this._eventHandlers[name]
		var idx = handlers.indexOf(callback)
		if (idx >= 0)
			handlers.splice(idx, 1)
		else
			console.log('failed to remove listener for', name, 'from', this)
		if (!handlers.length) {
			delete this._eventHandlers[name]
			if (name in this._onLastListener)
				this._onLastListener[name](name)
			else if ('' in this._onLastListener) {
				//log('first listener to', name)
				this._onLastListener[''](name)
			}
		}
	}
}
