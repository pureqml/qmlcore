var Player = function(ui) {
	var player = ui._context.createElement('video')
	player.dom.preload = "metadata"
	player.setAttribute("data-dashjs-player", "")

	this.element = player
	this.ui = ui
	this.setEventListeners()

	ui.element.remove()
	ui.element = player
	ui.parent.element.append(ui.element)

	this.dash = dashjs.MediaPlayer().create();
	this.dash.initialize(player.dom)
}

Player.prototype = Object.create(_globals.video.html5.backend.Player.prototype)

Player.prototype.setSource = function(url) {
	log("dashjs::setSource", url)
	this.ui.ready = false
	this.dash.attachSource(url)

	if (this.ui.autoPlay)
		this.play()
}

Player.prototype.setupDrm = function(type, options, callback, error) {
	var drmConfig = {}
	if (type === "widevine") {
		drmConfig["com.widevine.alpha"] = {
			"serverURL": options.laServer,
			"systemStringPriority": ["com.widevine.something", "com.widevine.alpha"],
			"priority": 1
		}
	} else if (type === "playready") {
		drmConfig["com.microsoft.playready"] = {
			"serverURL": options.laServer,
			"priority": 1,
			"systemStringPriority": ["com.microsoft.playready.something", "com.microsoft.playready.recommendation", "com.microsoft.playready.hardware", "com.microsoft.playready"]
		}
	} else {
		error ? error(new Error("Unknown or not supported DRM type " + type)) : log("Unknown or not supported DRM type " + type)
	}

	this.dash.setProtectionData(drmConfig)
	if (callback)
		callback()
}


exports.createPlayer = function(ui) {
	return new Player(ui)
}

exports.probeUrl = function(url) {
	return 10
}

Player.prototype.dispose = function() {
	_globals.video.html5.backend.Player.prototype.dispose.apply(this)
	this.dash.reset()
	this.dash = null
}

exports.Player = Player
