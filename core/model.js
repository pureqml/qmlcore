var ModelUpdateNothing = 0
var ModelUpdateInsert = 1
var ModelUpdateUpdate = 2

var ModelUpdateRange = function(type, length) {
	this.type = type
	this.length = length
}

exports.ModelUpdate = function() {
	this.count = 0
	this._reset()
}
exports.ModelUpdate.prototype.constructor = exports.ModelUpdate

exports.ModelUpdate.prototype._reset = function() {
	this._ranges = [new ModelUpdateRange(ModelUpdateNothing, this.count)]
	this._updateIndex = this.count
}

exports.ModelUpdate.prototype._setUpdateIndex = function(begin) {
	if (begin < this._updateIndex)
		this._updateIndex = begin
}

exports.ModelUpdate.prototype._find = function(index) {
	var ranges = this._ranges
	var i
	for(i = 0; i < ranges.length; ++i) {
		var range = ranges[i]
		if (index < range.length)
			return { index: i, offset: index }
		if (range.length > 0)
			index -= range.length
	}
	if (index != 0)
		throw new Error('invalid index ' + index)

	return { index: i - 1, offset: range.length }
}

exports.ModelUpdate.prototype.reset = function(model) {
	this.update(model, 0, Math.min(model.count, this.count))
	if (this.count < model.count) {
		this.insert(model, this.count, model.count)
	} else {
		this.remove(model, model.count, this.count)
	}
}

exports.ModelUpdate.prototype._merge = function() {
	var ranges = this._ranges
	for(var index = 1; index < ranges.length; ) {
		var range = ranges[index - 1]
		var nextRange = ranges[index]
		if (range.type === nextRange.type) {
			if (range.type === ModelUpdateInsert && range.length < 0 && nextRange.length > 0) {
				//removed + inserted rows reappers as updated
				var updated = Math.min(-range.length, nextRange.length)
				range.type = ModelUpdateUpdate
				nextRange.length += range.length
				range.length = updated
				if (index > 1)
					--index
			} else {
				range.length += nextRange.length
				ranges.splice(index, 1)
			}
		} else if (range.type == ModelUpdateInsert && range.length === 0) {
			ranges.splice(index, 1)
		} else
			++index
	}
}

exports.ModelUpdate.prototype._split = function(index, offset, type, length) {
	var ranges = this._ranges
	if (offset == 0) {
		ranges.splice(index, 0, new ModelUpdateRange(type, length))
		return index + 1
	} else {
		var range = ranges[index]
		var right = range.length - offset
		range.length = offset
		if (right != 0) {
			ranges.splice(index + 1, 0,
				new ModelUpdateRange(type, length),
				new ModelUpdateRange(range.type, right))
			return index + 2
		} else {
			ranges.splice(index + 1, 0,
				new ModelUpdateRange(type, length))
			return index + 2
		}
	}
}

exports.ModelUpdate.prototype.insert = function(model, begin, end) {
	if (begin >= end)
		return

	this._setUpdateIndex(begin)
	var ranges = this._ranges
	var d = end - begin
	this.count += d
	if (this.count != model.count)
		throw new Error('unbalanced insert ' + this.count + ' + [' + begin + '-' + end + '], model reported ' + model.count)

	var res = this._find(begin)
	var range = ranges[res.index]
	if (range.length == 0) { //first insert
		range.type = ModelUpdateInsert
		range.length += d
	} else {
		if (res.offset >= 0)
			this._split(res.index, res.offset, ModelUpdateInsert, d)
		else
			this._split(res.index + 1, 0, ModelUpdateInsert, d)
	}
	this._merge()
}

exports.ModelUpdate.prototype.remove = function(model, begin, end) {
	if (begin >= end)
		return

	this._setUpdateIndex(begin)
	var ranges = this._ranges
	var d = end - begin
	this.count -= d
	if (this.count != model.count)
		throw new Error('unbalanced remove ' + this.count + ' + [' + begin + '-' + end + '], model reported ' + model.count)

	var res = this._find(begin)
	var range = ranges[res.index]

	if (range.type == ModelUpdateInsert) {
		range.length -= d
	} else {
		var index = this._split(res.index, res.offset, ModelUpdateInsert, -d)
		while(d > 0) {
			var range = ranges[index]
			if (range.length <= d) {
				ranges.splice(index, 1)
				d -= range.length
			} else {
				range.length -= d
				d = 0
			}
		}
	}
	this._merge()
}

exports.ModelUpdate.prototype.update = function(model, begin, end) {
	if (begin >= end)
		return

	var ranges = this._ranges
	var n = end - begin
	var res = this._find(begin)
	var index = res.index

	var range = ranges[index]
	if (res.offset > 0) {
		ranges.splice(index + 1, 0, new ModelUpdateRange(range.type, range.length - res.offset))
		range.length = res.offset
		++index
		if (range.length == 0)
			throw new Error('invalid offset')
	}

	while(n > 0) {
		var range = ranges[index]
		var length = range.length
		switch(range.type) {
			case ModelUpdateNothing:
				if (length > n) {
					//range larger than needed
					range.length -= n
					ranges.splice(index, 0, new ModelUpdateRange(ModelUpdateUpdate, n))
					n -= length
				} else { //length <= n
					range.type = ModelUpdateUpdate
					n -= length
				}
				break
			case ModelUpdateInsert:
				if (length > 0)
					n -= length
				++index
				break
			case ModelUpdateUpdate:
				n -= length
				++index
				break
		}
	}
	this._merge()
}

exports.ModelUpdate.prototype.clear = function() {
	this.count = 0
	this._reset()
}

exports.ModelUpdate.prototype.apply = function(view, skipCheck) {
	var index = 0
	this._ranges.forEach(
		function(range) {
			var n = range.length
			switch(range.type) {
				case ModelUpdateInsert:
					if (n > 0) {
						view._insertItems(index, index + n)
						index += n
					} else if (n < 0) {
						view._removeItems(index, index - n)
					}
					break
				case ModelUpdateUpdate:
					view._updateItems(index, index + n)
					index += n
					break
				default:
					index += range.length
			}
		}
	)
	if (!skipCheck && view._items.length != this.count)
		throw new Error('unbalanced items update, view: ' + view._items.length + ', update:' + this.count)

	for(var i = this._updateIndex; i < this.count; ++i)
		view._updateDelegateIndex(i)
	this._reset()
}
