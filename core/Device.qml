Object {
	signal propertyUpadted;
	property string macAddess;
	property string modelName;
	property string deviceId;
	property string firmware;
	property string sdk;
	property bool supportingUhd;
	property bool supporting3d;

	constructor: {
		var backend = _globals.core.__deviceBackend
		if (!backend)
			throw new Error('no backend found')
		backend().createDevice(this)
	}

	onSdkChanged,
	onDeviceIdChanged,
	onFirmwareChanged,
	onMacAddessChanged,
	onModelNameChanged,
	onSupporting3dChanged,
	onSupportingUhdChanged: { this.propertyUpadted() }
}
