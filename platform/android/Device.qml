Object {
	property bool macAccessable: false;
	property string modelName: "androidtv";

	getDeviceId(callback): {
		callback(callback("android" + Math.random().toString(36).substr(2, 9)))
	}

	getMacAddress(callback): { callback("") }
}
