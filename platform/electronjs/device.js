var Device = function(ui) {
	var userAgent = _globals.core.userAgent.toLowerCase()
	var osToken = userAgent.substring(userAgent.indexOf("(") + 1, userAgent.indexOf(")"))
	var tokens = osToken.split(";")
	if (tokens.length > 0)
		ui.modelName = tokens[0]
	if (tokens.length > 1)
		ui.sdk = tokens[1]
}

exports.createDevice = function(ui) {
	return new Device(ui)
}

exports.Device = Device
