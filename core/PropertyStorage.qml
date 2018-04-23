/// object to hold named property synced with underlying storage
LocalStorage {
	signal ready;					///< the value now in a sync state with underlying storage
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
		this.getOrDefault(this.name, function(value) {
			this._setProperty('value', value)
			this.ready()
		}.bind(this), this.defaultValue)
	}

	///@private
	_write: {
		this._checkNameValid()
		if (this.value)
			this.set(this.name, this.value)
		else
			this.erase(this.name)
	}

	///@private
	onValueChanged: { this._write() }

	///@private
	onNameChanged: {
		this._setProperty('value', '')
		this._read()
	}

	onCompleted: {
		if (this.value) {
			this._setProperty('value', this.value)
			this.ready()
		}
	}
}
