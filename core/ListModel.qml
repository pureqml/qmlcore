Object {
	event reset;
	event rowsInserted;
	event rowsChanged;
	event rowsRemoved;

	property int count;

	clear: {
		this._rows = []
		count = this._rows.length
		this.reset()
	}

	append : {
		var l = this._rows.length
		this._rows.push(arguments[0])
		this.count = this._rows.length
		this.rowsInserted(l, l + 1)
	}

	insert : {
		var idx = arguments[0]
		var row = arguments[1]
		this._rows.splice(idx, 0, row)
		this.count = this._rows.length
		this.rowsInserted(idx, idx + 1)
	}

	set: {
		var idx = arguments[0]
		var row = arguments[1]
		this._rows[idx] = row
		this.rowChanged(idx, idx + 1)
	}

	get: {
		var idx = arguments[0]
		return this._rows[idx];
	}

	setProperty: {
		var idx = arguments[0]
		var name = arguments[1]
		var value = arguments[2]
		this._rows[idx][name] = value
		this.rowChanged(idx, idx + 1)
	}

	remove: {
		var idx = arguments[0]
		var n = arguments[1]
		if (n === undefined)
			n = 1
		this._rows.splice(idx, n)
		this.count = this._rows.length
		this.rowsRemoved(idx, n)
	}
}
