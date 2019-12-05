var Fingerprint = function() {
	log("creating fingerprint")
	this.__visited = []
	this.__text = ''
}

var FingerprintPrototype = Fingerprint.prototype

FingerprintPrototype._update = function(value, name) {
	if (!value || this.__visited.indexOf(value) >= 0)
		return

	this.__visited.push(value)
	var type = typeof value
	if (type === 'object') {
		if ('length' in value) {
			for(var i = 0; i < value.length; ++i) {
				this._update(value[i])
			}
		} else {
			for (var k in value) {
				this._update(value[k], k)
			}
		}
		return
	} else if (type === 'function') {
		return
	}

	//log("fingerprint update", value, name !== undefined? name: '')
	if (value !== undefined && value !== null)
		this.__text += String(value)
	this.__text += "\0"
}

FingerprintPrototype.update = function() {
	for(var i = 0; i < arguments.length; ++i) {
		this._update(arguments[i])
	}
}

FingerprintPrototype.finalize = function() {
	var r = $html5.fingerprint.sha1.sha1(this.__text)
	this.__text = ''
	return r
}

exports.Fingerprint = Fingerprint
