var Device = function(ui) {
	var context = ui._context
	var deviceString = context.system.os + "_" + context.system.browser
	deviceString = deviceString.replace(/\s/g, '')
	ui.deviceId = deviceString + "_" + Math.random().toString(36).substr(2, 9)
}

exports.createDevice = function(ui) {
	return new Device(ui)
}

exports.Device = Device
