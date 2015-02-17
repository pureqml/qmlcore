Object {
	event reset;
	event rowsInserted;
	event rowsChanged;
	event rowsRemoved;

	property int count;

	reset: {
		this._rows = []
		count = this._rows.length
		this._emitEvent('reset')
	}

	append : {
		var l = this._rows.length
		this._rows.push(arguments[0])
		count = this._rows.length
		rowsInserted(l, l + 1)
	}

	insert : {
		var idx = arguments[0]
		var row = arguments[1]
		this._rows.splice(idx, 0, row)
		count = this._rows.length
		rowsInserted(idx, idx + 1)
	}

	set: {
		var idx = arguments[0]
		var row = arguments[1]
		this._rows[idx] = row
		rowChanged(idx, idx + 1)
	}

	setProperty: {
		var idx = arguments[0]
		var name = arguments[1]
		var value = arguments[2]
		this._rows[idx][name] = value
		rowChanged(idx, idx + 1)
	}

	remove: {
		var idx = arguments[0]
		var n = arguments[1]
		if (n === undefined)
			n = 1
		this._rows.splice(idx, n)
		count = this._rows.length
		rowsRemoved(idx, n)
	}
}
