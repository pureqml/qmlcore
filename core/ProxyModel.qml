///provides target model's filtering and sorting
Model {
    property Object target;		///< target model object

	/// @private
	constructor: {
		this._indexes = []
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
		this.clear()
		var targetRows = this.target._rows
		if (!targetRows) {
			log("Bad target model")
			return
		}
		if (this._filter) {
			for (var i = 0; i < targetRows.length; ++i)
				if (this._filter(targetRows[i])) {
					var last = this._indexes.length
					this._indexes.push(i)
				}
		} else {
			for (var i = 0; i < targetRows.length; ++i) {
				this._indexes.push(i)
			}
		}
		if (this._cmp) {
			var self = this
			this._indexes = this._indexes.sort(function(a, b) { return self._cmp(targetRows[a], targetRows[b]) })
		}
		this.count = this._indexes.length
		this.rowsInserted(0, this.count)
	}

	///returns a model's row by index, throw exception if index is out of range or if requested row is non-object
	function get(idx) {
		var targetRows = this.target._rows
		if (!targetRows)
			throw new Error('Bad target model')
		if (idx < 0 || idx >= this._indexes.length)
			throw new Error('index ' + idx + ' out of bounds')
		var row = targetRows[this._indexes[idx]]
		if (!(row instanceof Object))
			throw new Error('row is non-object')
		row.index = idx
		return row
	}

	///remove all rows
	function clear() {
		this._indexes = []
		this.count = 0
		this.reset()
	}

	///append row to the model
	function append(row) {
		this.target.append(row)
	}

	///place row at requested index, throws exception when index is out of range
	function insert(idx, row) {
		if (idx < 0 || idx > this._indexes.length)
			throw new Error('index ' + idx + ' out of bounds')

		var targetIdx = this._indexes[idx]
		this.target.set(targetIdx, row)
	}

	///replace row at 'idx' position by 'row' argument, throws exception if index is out of range or if 'row' isn't Object
	function set(idx, row) {
		if (idx < 0 || idx >= this._indexes.length)
			throw new Error('index ' + idx + ' out of bounds')
		if (!(row instanceof Object))
			throw new Error('row is non-object')
		var targetIdx = this._indexes[idx]
		this.target.set(targetIdx, row)
	}

	///replace a row's property, throws exception if index is out of range or if 'row' isn't Object
	function setProperty(idx, name, value) {
		if (idx < 0 || idx >= this._indexes.length)
			throw new Error('index ' + idx + ' out of bounds')
		var targetIdx = this._indexes[idx]
		this.target.setProperty(targetIdx, name, value)
	}

	///remove rows from model from 'idx' to 'idx' + 'n' position
	function remove(idx, n) {
		if (idx < 0 || idx >= this._indexes.length)
			throw new Error('index ' + idx + ' out of bounds')
		this.target.remove(this._indexes[idx], n)
	}

	///this method is alias for 'append' method
	function addChild(child) {
		this.append(child)
	}

	/// @private
	onCompleted: {
		var target = this.target

		this.connectOn(target, 'reset', this._buildIndexMap.bind(this))
		this.connectOn(target, 'rowsInserted', this._buildIndexMap.bind(this))
		this.connectOn(target, 'rowsChanged', this._buildIndexMap.bind(this))
		this.connectOn(target, 'rowsRemoved', this._buildIndexMap.bind(this))

		this._buildIndexMap()
	}
}
