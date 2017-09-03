///simple model implementation
Object {
	signal reset;			///< model reset signal
	signal rowsInserted;	///< rows inserted signal
	signal rowsChanged;		///< rows changed signal
	signal rowsRemoved;		///< rows removed signal

	property int count;		///< model rows count
	property array data;	///< declarative way of assigning data

	///@private
	constructor: {
		this._rows = []
	}

	/**@param rows:Object raw rows array object
	setup models row with raw array*/
	function assign(rows) {
		this._rows = rows
		this.count = this._rows.length
		this.reset()
	}
	onDataChanged: { this.assign(value) }

	///clear whole model data
	function clear() { this.assign([]) }

	/**@param row:Object inserted row object
	add row to the model*/
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

	/**@param row:Object inserted row object
	@param idx:int position
	insert row to the model at the 'idx' position*/
	function insert(idx, row) {
		if (idx < 0 || idx > this._rows.length)
			throw new Error('index ' + idx + ' out of bounds (' + this._rows.length + ')')
		this._rows.splice(idx, 0, row)
		this.count = this._rows.length
		this.rowsInserted(idx, idx + 1)
	}

	/**@param row:Object new row value
	@param idx:int row's position to replace
	set new value to row at 'idx' position*/
	function set(idx, row) {
		if (idx < 0 || idx >= this._rows.length)
			throw new Error('index ' + idx + ' out of bounds (' + this._rows.length + ')')
		if (!(row instanceof Object))
			throw new Error('row is non-object')
		this._rows[idx] = row
		this.rowsChanged(idx, idx + 1)
	}

	/**@param idx:int row's position to replace
	get row ad 'idx' position*/
	function get(idx) {
		if (idx < 0 || idx >= this._rows.length)
			throw new Error('index ' + idx + ' out of bounds (' + this._rows.length + ')')
		var row = this._rows[idx]
		if (!(row instanceof Object))
			throw new Error('row is non-object')
		row.index = idx
		return row
	}

	/**@param idx:int row's position to replace
	@param name:string property's name
	@param value:Variant new value for the property
	change row at 'idx' position property named 'name' with new 'value' */
	function setProperty(idx, name, value) {
		if (idx < 0 || idx >= this._rows.length)
			throw new Error('index ' + idx + ' out of bounds (' + this._rows.length + ')')
		var row = this._rows[idx]
		if (!(row instanceof Object))
			throw new Error('row is non-object, invalid index? (' + idx + ')')

		if (row[name] !== value) {
			row[name] = value
			this.rowsChanged(idx, idx + 1)
		}
	}

	/**@param idx:int row's position to replace
	@param n:int rows count to remove
	remove 'n' rows from model start from 'idx' index */
	function remove(idx, n) {
		if (idx < 0 || idx >= this._rows.length)
			throw new Error('index ' + idx + ' out of bounds')
		if (n === undefined)
			n = 1
		this._rows.splice(idx, n)
		this.count = this._rows.length
		this.rowsRemoved(idx, idx + n)
	}

	/**@param row:Object inserted row object
	add row to the model (alias for 'append' method)*/
	function addChild(child) {
		this.append(child)
	}

	function forEach(callback) {
		return this._rows.forEach(callback)
	}
}
