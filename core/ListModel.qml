Object {
	signal reset;
	signal rowsInserted;
	signal rowsChanged;
	signal rowsRemoved;

	property int count;

	constructor: {
		this._rows = []
	}

	function clear() {
		this._rows = []
		this.count = this._rows.length
		this.reset()
	}

	function append(row) {
		var l = this._rows.length
		if (Array.isArray(row)) {
			Array.prototype.push.apply(this._rows, row)
			this.count = this._rows.length
			this.rowsInserted(l, l + row.length)
		} else {
			this._rows.push(row)
			this.count = this._rows.length
			this.rowsInserted(l, l + 1)
		}
	}

	function insert(idx, row) {
		if (idx < 0 || idx > this._rows.length)
			throw 'index ' + idx + ' out of bounds'
		this._rows.splice(idx, 0, row)
		this.count = this._rows.length
		this.rowsInserted(idx, idx + 1)
	}

	function set(idx, row) {
		if (idx < 0 || idx >= this._rows.length)
			throw 'index ' + idx + ' out of bounds'
		if (!(row instanceof Object))
			throw 'row is non-object'
		this._rows[idx] = row
		this.rowsChanged(idx, idx + 1)
	}

	function get(idx) {
		if (idx < 0 || idx >= this._rows.length)
			throw 'index ' + idx + ' out of bounds'
		var row = this._rows[idx]
		if (!(row instanceof Object))
			throw 'row is non-object'
		row.index = idx
		return row
	}

	function setProperty(idx, name, value) {
		if (idx < 0 || idx >= this._rows.length)
			throw 'index ' + idx + ' out of bounds'
		var row = this._rows[idx]
		if (!(row instanceof Object))
			throw 'row is non-object, invalid index? (' + idx + ')'

		row[name] = value
		this.rowsChanged(idx, idx + 1)
	}

	function remove(idx, n) {
		if (idx < 0 || idx >= this._rows.length)
			throw 'index ' + idx + ' out of bounds'
		if (n === undefined)
			n = 1
		this._rows.splice(idx, n)
		this.count = this._rows.length
		this.rowsRemoved(idx, n)
	}

	function addChild(child) {
		this.append(child)
	}

}
