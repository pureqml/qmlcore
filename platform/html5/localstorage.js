var LocalStorage = function(parent) {
	if (parent && parent.name !== undefined) {
		// TODO: implement properties sunchronization using parent._setProperty() and parent.ready()
	}
	this._storage = window.localStorage;
	if (!this._storage)
		throw new Error("no local storage support")
}

LocalStorage.prototype.get = function(name, callback, error) {
	var value = this._storage.getItem(name)
	if (value !== null)
		callback(value)
	else
		error(new Error('no item with name ' + name))
}

LocalStorage.prototype.set = function(name, value) {
	this._storage.setItem(name, value)
}

LocalStorage.prototype.erase = function(name, error) {
	this._storage.removeItem(name)
}

exports.createLocalStorage = function(parent) {
	return new LocalStorage(parent)
}

exports.LocalStorage = LocalStorage
