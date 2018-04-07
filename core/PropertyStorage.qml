/// object to hold named property synced with underlying storage
LocalStorage {
	property string name;			///< stored property key name
	property string value;			///< stored property value
	property string defaultValue;	///< default init value

	///@private
	_checkNameValid: {
		if (!this.name)
			throw new Error('empty property name')
	}

	///@private
	_read: {
		this._checkNameValid()
		this.get(this.name,
			function(value) { this._setProperty('value', value) }.bind(this),
			function() { this._setProperty('value', this.defaultValue) }.bind(this))
	}

	///@private
	_write: {
		this._checkNameValid()
		if (this.value !== undefined && this.value !== null)
			this.set(this.name, this.value)
		else
			this.erase(this.name)
	}

	///@private
	onValueChanged: { this._write() }

	///@private
	onNameChanged: {
		this._setProperty('value', undefined)
		this._read()
	}
}
