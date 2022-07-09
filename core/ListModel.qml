///simple model implementation
Model {
	property array data;				///< declarative way of assigning data
	property array localizedFields; 	///< fields which would be localised automatically (passed to tr function before return)

	///@private
	constructor: {
		this._rows = []
		this.connectOnChanged(this._context, 'language', this._languageChanged.bind(this))
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
			if (row.length === 0)
				return
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

	/**@param idx:int row's position to get
	get row ad 'idx' position*/
	function get(idx) {
		if (idx < 0 || idx >= this._rows.length)
			throw new Error('index ' + idx + ' out of bounds (' + this._rows.length + ')')

		var row = this._rows[idx]
		if (!(row instanceof Object))
			throw new Error('row is non-object')

		var localizedFields = this.localizedFields
		var n = localizedFields.length;
		if (n <= 0) {
			row.index = idx
			return row
		}

		var res = Object.assign({}, row)
		res.index = idx
		var context = this._context
		for(var i = 0; i < n; ++i) {
			var name = localizedFields[i]
			if (name in res) {
				res[name] = context.tr(res[name])
			}
		}
		return res
	}

	/**@param idx:int row's position to get
	@param name:string property to get
	get property from row at 'idx' position*/
	function getProperty(idx, name) {
		if (name === 'index')
			return idx

		if (idx < 0 || idx >= this._rows.length)
			throw new Error('index ' + idx + ' out of bounds (' + this._rows.length + ')')
		var row = this._rows[idx]
		if (!(row instanceof Object))
			throw new Error('row is non-object')
		return row[name]
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
			return true
		}
		else
			return false
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

	function move(from, to) {
		while(from < 0) {
			from += this._rows.length;
		}
		while(to < 0) {
			to += this._rows.length;
		}
		if(to >= this._rows.length) {
			var k = to - this._rows.length;
			while((k--) + 1) {
				this._rows.push(undefined);
			}
		}
		this._rows.splice(to, 0, this._rows.splice(from, 1)[0]);
		this.reset();
	}

	function _languageChanged() {
		if (this.localizedFields.length > 0) {
			this.reset()
		}
	}
}
