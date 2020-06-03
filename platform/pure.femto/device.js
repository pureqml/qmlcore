exports.createDevice = function(ui) {
	var info = ui._context.backend._deviceInfo
	Object.assign(ui, info)

	ui.lockOrientation = function(orientation) {
		fd.setDeviceFeature('orientation', orientation)
	}

	ui.keepScreenOn = function(enable) {
		fd.setDeviceFeature('keep-screen-on', enable)
	}

	ui.setFullScreen = function(enable) {
		fd.setDeviceFeature('fullscreen', enable)
	}
}
