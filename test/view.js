var View = function() {
	this._items = { length : 0 }
}

View.prototype._insertItems = function(begin, end) {
	if (begin < end)
		this._items.length += end - begin
}
View.prototype._discardItems = function(begin, end)
{
	if (begin < end)
		this._items.length -= end - begin
}
View.prototype._updateDelegate = function(idx) { }
View.prototype._updateDelegateIndex = function(idx) { }

module.exports = View
