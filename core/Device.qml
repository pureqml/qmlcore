/// Object which contains device specific information like model name. MAC address etc.
Object {
	signal propertyUpdated;			///< this signal is emited every time when one of the property was changed
	property string macAddress;		///< device MAC address if its available for current platform
	property string modelName;		///< device model name
	property string deviceId;		///< unique device id or random generated id if its not supported
	property string firmware;		///< firmware version
	property string language;		///< device langgcode
	property string country;		///< device country code
	property string sdk;			///< SDK version
	property string ip;				///< device IP address if its available
	property string runtime;		///< pureqml specific runtime provider, cordova/native

	property bool standByMode;		///< Stand by mode flag (if its supported)
	property bool supportingUhd;	///< UHD (4K) supporting flag
	property bool supportingHdr;	///< HDR supporting flag
	property bool supporting3d;		///< 3D Video supporting flag

	constructor: {
		var backend = $core.__deviceBackend
		if (!backend)
			throw new Error('no backend found')

		this.impl = backend().createDevice(this)
	}

	onSdkChanged,
	onDeviceIdChanged,
	onFirmwareChanged,
	onMacAddessChanged,
	onModelNameChanged,
	onSupporting3dChanged,
	onSupportingUhdChanged: { this.propertyUpdated() }

	onStandByModeChanged: {
		if (!this.impl) {
			throw new Error('toggleStandByMode: no backend found')
			return
		}

		this.impl.toggleStandByMode()
	}
}
