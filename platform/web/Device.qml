Object {
	property bool macAccessable: false;

	getDeviceId(callback): { callback(this._context.system.os + "_" + this._context.system.browser) }
	getMacAddress(callback): { callback("") }
}
