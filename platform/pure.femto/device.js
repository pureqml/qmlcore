exports.createDevice = function(ui) {
	var info = fd.getDeviceInfo()
	Object.assign(ui, info)
}
