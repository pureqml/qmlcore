Object {
	signal reset;
	signal rowsInserted;
	signal rowsChanged;
	signal rowsRemoved;

	property int count;

	clear: {
		this._rows = []
		count = this._rows.length
		this.reset()
	}

	append(row) : {
		var l = this._rows.length
		row.index = l
		this._rows.push(row)
		this.count = this._rows.length
		this.rowsInserted(l, l + 1)
	}

	insert(idx, row) : {
		row.index = idx
		this._rows.splice(idx, 0, row)
		this.count = this._rows.length
		this.rowsInserted(idx, idx + 1)
	}

	set(idx, row): {
		row.index = idx
		this._rows[idx] = row
		this.rowsChanged(idx, idx + 1)
	}

	get(idx): {
		return this._rows[idx]
	}

	setProperty(idx, name, value): {
		this._rows[idx][name] = value
		this.rowsChanged(idx, idx + 1)
	}

	remove(idx, n): {
		if (n === undefined)
			n = 1
		this._rows.splice(idx, n)
		this.count = this._rows.length
		this.rowsRemoved(idx, n)
	}
}
