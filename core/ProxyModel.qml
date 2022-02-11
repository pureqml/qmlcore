///provides target model's filtering and sorting
Model {
    property Object target;		///< target model object

	/// @private
	constructor: {
		this._indices = []
	}

	rebuild: { this._buildIndexMap() }

	///this method set target model rows filter function, 'filter' function must return boolean value, 'true' - when row must be displayed, 'false' otherwise
	function setFilter(filter) {
		this._filter = filter
		this._buildIndexMap()
	}

	///this method set a comparison function, target model rows are sorted in ascending order according to a comparison function 'cmp'
	function setCompare(cmp) {
		this._cmp = cmp
		this._buildIndexMap()
	}

	/// @private
	function _buildIndexMap() {
		this.count = 0
		this._indices = []
		this.reset()
		var targetRows = this.target._rows
		if (!targetRows) {
			log("Bad target model")
			return
		}
		var indices = []
		var targetSize = targetRows.length
		if (this._filter) {
			for (var i = 0; i < targetSize; ++i)
				if (this._filter(targetRows[i])) {
					indices.push(i)
				}
		} else {
			for (var i = 0; i < targetSize; ++i) {
				indices.push(i)
			}
		}
		if (this._cmp) {
			var self = this
			indices.sort(function(a, b) { return self._cmp(targetRows[a], targetRows[b]) })
		}

		this._indices = indices
		this.count = this._indices.length
		this.rowsInserted(0, this.count)
	}

	///@private
	function _findIndex(row, rowTargetIndex) {
		var rows = this.target._rows
		var indices = this._indices
		var cmp = this._cmp
		var l = 0
		var h = indices.length
		while(l < h) {
			var m = (l + h) >> 1
			var targetIndex = indices[m]
			var r = cmp? cmp(row, rows[targetIndex]): rowTargetIndex - targetIndex
			if (r > 0) {
				l = m + 1
			} else if (r < 0) {
				h = m
			} else {
				return m
			}
		}
		return h
	}

	///@private
	function _insertRows(begin, end, update) {
		var rows = this.target._rows
		var indices = this._indices
		var filter = this._filter
		var cmp = this._cmp
		var insert = []

		var rangeSize = update? 0: end - begin
		for(var i = 0, n = indices.length; i < n; ++i) {
			if (indices[i] >= begin)
				indices[i] += rangeSize
		}

		for(var i = begin; i < end; ++i) {
			var row = rows[i]
			if (filter && !filter(row))
				continue

			var insertPos = this._findIndex(row, i)
			insert.push([insertPos, i])
		}

		for(var i = 0, n = insert.length; i < n; ++i) {
			var el = insert[i]
			var pos = el[0]
			indices.splice(pos, 0, el[1])
			++this.count
			this.rowsInserted(pos, pos + 1)
		}
	}

	///@private
	function _updateRows(begin, end) {
		this._removeRows(begin, end, true)
		this._insertRows(begin, end, true)
	}

	///@private
	function _removeRows(begin, end, update) {
		var indices = this._indices
		var remove = []
		var rangeSize = update? 0: end - begin
		for(var i = 0; i < indices.length; ++i) {
			var targetIdx = indices[i]
			if (targetIdx >= begin) {
				if (targetIdx < end) {
					indices.splice(i, 1)
					remove.push(i)
					--i
				} else
					indices[i] -= rangeSize
			}
		}
		for (var i = 0; i < remove.length; ++i) {
			var index = remove[i]
			--this.count
			this.rowsRemoved(index, index + 1)
		}
	}

	///returns a model's row by index, throw exception if index is out of range or if requested row is non-object
	function get(idx) {
		var targetRows = this.target._rows
		if (!targetRows)
			throw new Error('Bad target model')
		if (idx < 0 || idx >= this._indices.length)
			throw new Error('index ' + idx + ' out of bounds')
		var row = targetRows[this._indices[idx]]
		if (!(row instanceof Object))
			throw new Error('row is non-object')
		row = Object.assign({}, row) //shallow copy to avoid overwriting index in original model.
		row.index = idx
		return row
	}

	///returns a model's property by index, throw exception if index is out of range or if requested row is non-object
	function getProperty(idx, name) {
		var targetRows = this.target._rows
		if (!targetRows)
			throw new Error('Bad target model')
		if (idx < 0 || idx >= this._indices.length)
			throw new Error('index ' + idx + ' out of bounds')
		if (name === 'index')
			return idx
		var row = targetRows[this._indices[idx]]
		if (!(row instanceof Object))
			throw new Error('row is non-object')
		return row[name]
	}

	///remove all rows
	function clear() {
		this._indices = []
		this.count = 0
		this.target.clear()
	}

	///append row to the model
	function append(row) {
		this.target.append(row)
	}

	///replace row at 'idx' position by 'row' argument, throws exception if index is out of range or if 'row' isn't Object
	function set(idx, row) {
		if (idx < 0 || idx >= this._indices.length)
			throw new Error('index ' + idx + ' out of bounds')
		if (!(row instanceof Object))
			throw new Error('row is non-object')
		var targetIdx = this._indices[idx]
		this.target.set(targetIdx, row)
	}

	///replace a row's property, throws exception if index is out of range or if 'row' isn't Object
	function setProperty(idx, name, value) {
		if (idx < 0 || idx >= this._indices.length)
			throw new Error('index ' + idx + ' out of bounds')
		var targetIdx = this._indices[idx]
		this.target.setProperty(targetIdx, name, value)
	}

	///remove rows from model from 'idx' to 'idx' + 'n' position
	function remove(idx, n) {
		if (idx < 0 || idx >= this._indices.length)
			throw new Error('index ' + idx + ' out of bounds')
		this.target.remove(this._indices[idx], n)
	}

	///this method is alias for 'append' method
	function addChild(child) {
		this.append(child)
	}

	/// @private
	onCompleted: {
		var target = this.target

		this.connectOn(target, 'reset', this._buildIndexMap.bind(this))
		this.connectOn(target, 'rowsInserted', this._insertRows.bind(this))
		this.connectOn(target, 'rowsChanged', this._updateRows.bind(this))
		this.connectOn(target, 'rowsRemoved', this._removeRows.bind(this))

		this._buildIndexMap()
	}
}
