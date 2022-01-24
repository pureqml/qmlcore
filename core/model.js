var ModelUpdateNothing = 0
var ModelUpdateInsert = 1
var ModelUpdateRemove = 2
var ModelUpdateUpdate = 3
var ModelUpdateFinish = 4

exports.ModelUpdate = function() {
	this.rows = []
}
exports.ModelUpdate.prototype.constructor = exports.ModelUpdate

exports.ModelUpdate.prototype.reset = function(model) {
	var n = model.count
	var rows = this.rows = new Array(n)
	for (var i = 0; i < n; ++i)
		rows[i] = [i, true]
}

exports.ModelUpdate.prototype.insert = function(model, begin, end) {
	if (begin >= end)
		return

	var d = end - begin
	var rows = this.rows
	var args = [begin, 0]
	for(var i = 0; i < d; ++i)
		args.push([begin + i, true])
	rows.splice.apply(rows, args)
	if (rows.length != model.count)
		throw new Error('unbalanced insert ' + rows.length + ' + [' + begin + '-' + end + '], model reported ' + model.count)
}

exports.ModelUpdate.prototype.remove = function(model, begin, end) {
	if (begin >= end)
		return

	var d = end - begin
	var rows = this.rows
	rows.splice(begin, d)
	if (rows.length != model.count)
		throw new Error('unbalanced remove ' + rows.length + ' + [' + begin + '-' + end + '], model reported ' + model.count)
}

exports.ModelUpdate.prototype.update = function(model, begin, end) {
	if (begin >= end)
		return

	var rows = this.rows;
	for(var i = begin; i < end; ++i)
		rows[i][1] = true
}

exports.ModelUpdate.prototype.clear = function() {
	this.rows = []
}

exports.ModelUpdate.prototype.apply = function(view, skipCheck) {
	var rows = this.rows
	var currentRange = ModelUpdateNothing
	var currentRangeStartedAt = 0
	var currentRangeSize = 0
	var updated = false

	//log("APPLY ", rows)

	var apply = function(range, index, size) {
		if (size === undefined)
			size = 1

		if (currentRange === range) {
			currentRangeSize += size
			return
		}

		if (currentRangeSize > 0) {
			switch(currentRange) {
				case ModelUpdateNothing:
					break
				case ModelUpdateUpdate:
					updated = true
					view._updateItems(currentRangeStartedAt, currentRangeStartedAt + currentRangeSize)
					break
				case ModelUpdateInsert:
					updated = true
					view._insertItems(currentRangeStartedAt, currentRangeStartedAt + currentRangeSize)
					break
				case ModelUpdateRemove:
					updated = true
					view._removeItems(currentRangeStartedAt, currentRangeStartedAt + currentRangeSize)
					break
			}
		}

		currentRange = range
		currentRangeStartedAt = index
		currentRangeSize = size
	}

	var src_n = rows.length
	var dst_n = view._items.length
	var offset = 0
	for(var src = 0; src < src_n; ) {
		var row = rows[src]
		var dst = row[0] + offset
		if (src >= dst_n) {
			apply(ModelUpdateInsert, src, src_n - dst_n)
			break
		} else if (dst === src) {
			apply(row[1]? ModelUpdateUpdate: ModelUpdateNothing, src)
			if (offset !== 0)
				view._updateDelegateIndex(src)
			++src
			++dst
		} else if (dst > src) {
			//removing gap
			var d = dst - src
			apply(ModelUpdateRemove, src, d)
			offset += -d
		} else { //dst < src
			var d = src - dst
			if (currentRange === ModelUpdateUpdate && d == currentRangeSize) {
				//check here if we have an equivalent range of update,
				//signal insert first instead of update (on the next loop iteration)
				offset += d
				currentRange = ModelUpdateInsert
			} else {
				offset += d
				src += d
				apply(ModelUpdateInsert, dst + d, d)
			}
		}
	}
	apply(ModelUpdateFinish, dst_n)

	dst_n = view._items.length //update length
	if (dst_n > src_n) {
		view._removeItems(src_n, dst_n)
	} else if (src_n > dst_n) {
		view._insertItems(dst_n, src_n)
	}
	if (!skipCheck && view._items.length != src_n )
		throw new Error('unbalanced items update, view: ' + view._items.length + ', update:' + src_n)

	for(var i = 0; i < src_n; ++i) {
		var row = rows[i]
		row[0] = i
		row[1] = false
	}
	return updated
}

var ArrayModelWrapper = exports.ArrayModelWrapper = function (data) { this.data = data; this.count = data.length }
ArrayModelWrapper.prototype.get = function(idx)  { return { value: this.data[idx] } }
ArrayModelWrapper.prototype.on = function() { }
ArrayModelWrapper.prototype.removeListener = function() { }
