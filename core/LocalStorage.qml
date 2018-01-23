/// object for storing value by key name
Object {
	property string name;		///< stored property key name
	property string value;		///< stored property value

	constructor: {
		var backend = _globals.core.__localStorageBackend
		this.impl = backend().createLocalStorage(this)
	}

	///read 'name' property from storage and set its value to 'value' property
	read: { this.impl.read() }

	/**@param name:string stored item name
	return stored item by name if it exists*/
	getItem(name): { return this.impl.getItem(name) }

	///@private
	onValueChanged: { this.impl.saveItem() }

	///@private
	onNameChanged: { this.read() }

	///@private
	onCompleted: { this.read() }
}
