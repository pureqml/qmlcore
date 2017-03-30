///@private
EventEmitter {
	///@private
	constructor: {
		this._onFirstListener = {}
		this._onLastListener = {}
	}

	///@private
	function discard() {
		_globals.core.EventEmitter.prototype.discard.apply(this)
	}

	///@private
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

	///@private
	function onListener (name, first, last) {
		this._onFirstListener[name] = first
		this._onLastListener[name] = last
	}

	///@private
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
