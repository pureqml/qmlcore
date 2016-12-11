var model = require('../core/model.js')

var ModelMock = function() {
	this.updater = new model.ModelUpdate()
	this.count = 0
}

ModelMock.prototype.reset = function(n) {
	this.count = n
	this.updater.reset(this)
}

ModelMock.prototype.insert = function(begin, end) {
	this.count += end - begin
	this.updater.insert(this, begin, end)
}

ModelMock.prototype.remove = function(begin, end) {
	this.count -= end - begin
	this.updater.remove(this, begin, end)
}

ModelMock.prototype.update = function(begin, end) {
	this.updater.update(this, begin, end)
}

ModelMock.prototype.apply = function(view) {
	this.updater.apply(view)
}

module.exports = ModelMock
