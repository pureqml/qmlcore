var Player = function(ui) {
	var player = ui._context.createElement('video')
	player.dom.preload = "metadata"
	player.setAttribute("data-dashjs-player", "")

	this.element = player
	this.ui = ui
	this.setEventListeners()

	if (ui.element)
		ui.element.remove()
	ui.element = player
	ui.parent.element.append(ui.element)

	ui.dash = dashjs.MediaPlayer().create();
	ui.dash.initialize(player.dom)
}

Player.prototype = Object.create(_globals.video.html5.backend.Player.prototype)

Player.prototype.setSource = function(url) {
	this.ui.ready = false
	this.ui.dash.attachSource(url)
}


exports.createPlayer = function(ui) {
	return new Player(ui)
}

exports.probeUrl = function(url) {
	return 10
}

Player.prototype.dispose = function() {
	_globals.video.html5.backend.Player.prototype.dispose.apply(this)
	ui.dash.reset()
	ui.dash = null
}

exports.Player = Player
