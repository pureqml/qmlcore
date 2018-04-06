var LocalStorage = function(control) {
	this._control = control
	this._storage = window.localStorage;
	if (!this._storage)
		throw new Error("no local storage support")
}

LocalStorage.prototype.getItem = function(name) {
	return this._storage.getItem(name)
}

LocalStorage.prototype.read = function() {
	var control = this._control
	if (control.name) {
		var value = this._storage.getItem(control.name)
		control.value = value !== null ? value : undefined
	}
}

LocalStorage.prototype.saveItem = function() {
	var control = this._control
	this._storage.setItem(control.name, control.value)
}

exports.createLocalStorage = function(control) {
	return new LocalStorage(control)
}

exports.LocalStorage = LocalStorage
