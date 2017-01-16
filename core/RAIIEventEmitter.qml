EventEmitter {
	constructor: {
		this._onFirstListener = {}
		this._onLastListener = {}
	}

	function discard() {
		_globals.core.EventEmitter.prototype.discard.apply(this)
	}

	function on (name, callback) {
		if (!(name in this._eventHandlers)) {
			if (name in this._onFirstListener) {
				//log('first listener to', name)
				this._onFirstListener[name](name)
			} else if ('' in this._onFirstListener) {
				//log('first listener to', name)
				this._onFirstListener[''](name)
			}
			if (this._eventHandlers[name])
				throw new Error('listener callback added event handler')
		}
		_globals.core.EventEmitter.prototype.on.call(this, name, callback)
	}

	function onListener (name, first, last) {
		this._onFirstListener[name] = first
		this._onLastListener[name] = last
	}

	function removeAllListeners(name) {
		_globals.core.EventEmitter.prototype.removeAllListeners.call(this, name)
		if (name in this._onLastListener)
			this._onLastListener[name](name)
		else if ('' in this._onLastListener) {
			//log('first listener to', name)
			this._onLastListener[''](name)
		}
	}
}
