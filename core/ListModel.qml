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
		this._rows.push(row)
		this.count = this._rows.length
		this.rowsInserted(l, l + 1)
	}

	function insert(idx, row) {
		this._rows.splice(idx, 0, row)
		this.count = this._rows.length
		this.rowsInserted(idx, idx + 1)
	}

	function set(idx, row) {
		this._rows[idx] = row
		this.rowsChanged(idx, idx + 1)
	}

	function get(idx) {
		var row = this._rows[idx]
		row.index = idx
		return row
	}

	function setProperty(idx, name, value) {
		this._rows[idx][name] = value
		this.rowsChanged(idx, idx + 1)
	}

	function remove(idx, n) {
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
