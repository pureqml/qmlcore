var Device = function(ui) {
	var context = ui._context
	if ($manifest$system$fingerprint) {
		var fingerprint = new $html5.fingerprint.fingerprint.Fingerprint()
		context.backend.fingerprint(context, fingerprint)
		ui.deviceId = fingerprint.finalize()
		log("deviceId", ui.deviceId)
	} else {
		var deviceString = context.system.os + "_" + context.system.browser
		deviceString = deviceString.replace(/\s/g, '')
		ui.deviceId = deviceString + "_" + Math.random().toString(36).substr(2, 9)
	}
}

exports.createDevice = function(ui) {
	return new Device(ui)
}

exports.Device = Device
