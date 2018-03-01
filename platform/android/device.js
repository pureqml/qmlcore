var Device = function(ui) {
	function onDeviceReady() {
		ui.deviceId = device.uuid
		ui.modelName = device.model
		ui.firmware = device.version
	}
	ui._context.document.on('deviceready', onDeviceReady);
}

exports.createDevice = function(ui) {
	return new Device(ui)
}

exports.Device = Device
