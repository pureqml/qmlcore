Object {
	signal reset;
	signal rowsInserted;
	signal rowsChanged;
	signal rowsRemoved;
	property int count;
    property Object target;

	constructor: {
		this._indexes = []
	}

	function setFilter(filter) {
		this._filter = filter
		this._buildIndexMap()
	}

	function setCompare(cmp) {
		this._cmp = cmp
		this._buildIndexMap()
	}

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

	function clear() {
		this._indexes = []
		this.count = 0
		this.reset()
	}

	function append(row) {
		this.target.append = row
	}

	function insert(idx, row) {
		if (idx < 0 || idx > this._indexes.length)
			throw new Error('index ' + idx + ' out of bounds')

		var targetIdx = this._indexes[idx]
		this._rows.splice(targetIdx, 0, row)
		this.target.rowsInserted(targetIdx, targetIdx + 1)
	}

	function set(idx, row) {
		if (idx < 0 || idx >= this._indexes.length)
			throw new Error('index ' + idx + ' out of bounds')
		if (!(row instanceof Object))
			throw new Error('row is non-object')
		var targetIdx = this._indexes[idx]
		this.target._rows[targetIdx] = row
		this.target.rowsChanged(targetIdx, targetIdx + 1)
	}

	function setProperty(idx, name, value) {
		if (idx < 0 || idx >= this._indexes.length)
			throw new Error('index ' + idx + ' out of bounds')
		var targetIdx = this._indexes[idx]
		var row = this.target._rows[targetIdx]
		if (!(row instanceof Object))
			throw new Error('row is non-object, invalid index? (' + idx + ')')

		row[name] = value
		this.target.rowsChanged(targetIdx, targetIdx + 1)
	}

	function remove(idx, n) {
		if (idx < 0 || idx >= this._indexes.length)
			throw new Error('index ' + idx + ' out of bounds')
		this.target.remove(this._indexes[idx], n)
	}

	function addChild(child) {
		this.append(child)
	}

	function _onReset() {
		this.clear()
	}

	function _onRowsInserted(begin, end) {
		log("TODO: impl", begin, end)
	}

	function _onRowsChanged(begin, end) {
		log("TODO: impl", begin, end)
	}

	function _onRowsRemoved(begin, end) {
		log("TODO: impl", begin, end)
	}

	onCompleted: {
		this.target.on('reset', this._onReset.bind(this))
		this.target.on('rowsInserted', this._onRowsInserted.bind(this))
		this.target.on('rowsChanged', this._onRowsChanged.bind(this))
		this.target.on('rowsRemoved', this._onRowsRemoved.bind(this))

		this._buildIndexMap()
	}
}
