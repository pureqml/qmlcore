exports.createDevice = function(ui) {
	var info = fd.getDeviceInfo()
	Object.assign(ui, info)
	ui._context.system.device = info.device
}
