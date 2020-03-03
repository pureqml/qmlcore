exports.createDevice = function(ui) {
	var info = fd.getDeviceInfo()
	Object.assign(ui, info)
	ui._context.system.device = info.device
	ui.lockOrientation = function(orientation) {
		fd.setDeviceFeature('orientation', orientation)
	}

	ui.keepScreenOn = function(enable) {
		fd.setDeviceFeature('keep-screen-on', enable)
	}
}
