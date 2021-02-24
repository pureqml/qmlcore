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

	ui.dash = dashjs.MediaPlayer().create();
	ui.dash.initialize(player.dom)
}

Player.prototype = Object.create(_globals.video.html5.backend.Player.prototype)

Player.prototype.setSource = function(url) {
	var ui = this.ui
	this.ui.ready = false
	var startUrl = ui.startPosition ? url + "#t=" + ui.startPosition : url
	this.ui.dash.attachSource(startUrl)

	if (!this._drmType)
		return

	var type = this._drmType
	var selectedDrm = ""
	if (type === "widevine")
		selectedDrm = "com.widevine.alpha"
	else if (type === "playready")
		selectedDrm = "com.microsoft.playready"

	this.ui.dash.setProtectionData({ selectedDrm: { "serverURL": this._options.laServer } });
}

Player.prototype.setupDrm = function(type, options, callback, error) {
	var ui = this.ui
	this._drmType = type
	this._options = options
	if (callback)
		callback()
}

exports.createPlayer = function(ui) {
	return new Player(ui)
}

exports.probeUrl = function(url) {
	return 1005000
}

exports.Player = Player
