///@private
EventEmitter {
	///@private
	constructor: {
		this._onListener = {}
	}

	///@private
	function on (name, callback) {
		if (!(name in this._eventHandlers)) {
			if (name in this._onListener) {
				//log('first listener to', name)
				this._onListener[name][0](name)
			} else if ('' in this._onListener) {
				//log('first listener to', name)
				this._onListener[''][0](name)
			}
			if (this._eventHandlers[name])
				throw new Error('listener callback added event handler')
		}
		$ns$core.EventEmitter.prototype.on.call(this, name, callback)
	}

	///@private
	function onListener (name, first, last) {
		this._onListener[name] = [first, last]
	}

	///@private
	function removeAllListeners(name) {
		$ns$core.EventEmitter.prototype.removeAllListeners.call(this, name)
		if (name in this._onListener)
			this._onListener[name][1](name)
		else if ('' in this._onListener) {
			//log('first listener to', name)
			this._onListener[''][1](name)
		}
	}
}
