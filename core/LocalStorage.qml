Object {
	property string name;
	property string value;

	onNameChanged: {
		this.read()
	}

	onValueChanged: {
		this.init()
		//log("localStorage: write", this.name, this.value)
		this._storage.setItem(this.name, this.value)
	}

	read: {
		this.init()
		var value = this.name? this._storage.getItem(this.name): "";
		if (value !== null && value !== undefined)
			this.value = value
		//log("localStorage: read", this.name, this.value)
	}

	init: {
		if (!this._storage) {
			this._storage = this._context.backend.localStorage
			if (!this._storage)
				throw new Error("no local storage support")
		}
	}

	onCompleted: {
		this.read()
	}
}
