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

	this.dash = dashjs.MediaPlayer().create();
	this.dash.initialize(player.dom)
}

Player.prototype = Object.create(_globals.video.html5.backend.Player.prototype)

Player.prototype.setSource = function(url) {
	this.ui.ready = false
	this.dash.attachSource(url)
	if (this.ui.autoPlay)
		this.play()
}

exports.createPlayer = function(ui) {
	return new Player(ui)
}

exports.probeUrl = function(url) {
	return 100500
}

Player.prototype.dispose = function() {
	_globals.video.html5.backend.Player.prototype.dispose.apply(this)
	this.dash.reset()
	this.dash = null
}

exports.Player = Player
