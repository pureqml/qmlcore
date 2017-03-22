Object {
	property string name;		///< stored property key name
	property string value;		///< stored property value

	///@internal
	onNameChanged: {
		this.read()
	}

	///@internal
	onValueChanged: {
		this.init()
		this._storage.setItem(this.name, this.value)
	}

	///@private
	read: {
		this.init()
		var value = this.name? this._storage.getItem(this.name): "";
		if (value !== null && value !== undefined)
			this.value = value
	}

	///@private
	init: {
		if (!this._storage) {
			this._storage = window.localStorage;
			if (!this._storage)
				throw new Error("no local storage support")
		}
	}

	///@private
	onCompleted: {
		this.read()
	}
}
