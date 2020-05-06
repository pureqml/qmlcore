var Device = function(ui) {
	function onDeviceReady() {
		ui.deviceId = device.uuid
		ui.modelName = device.model
		ui.firmware = device.version
		ui.sdk = device.version
		if (clientInformation && clientInformation.language)
			ui.language = device.version
	}
	ui._context.document.on('deviceready', onDeviceReady);

	var screen = window.screen
	if (screen) {
		ui.lockOrientation = function(orientation) { screen.orientation.lock(orientation) }.bind(ui)
		ui.unlockOrientation = function() { screen.orientation.unlock() }.bind(ui)
	} else {
		log("'screen' is undefined, add 'cordova-plugin-screen-orientation' plugin")
	}
}

exports.createDevice = function(ui) {
	return new Device(ui)
}

exports.Device = Device
