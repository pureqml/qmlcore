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

	this.setAutoPlay(ui.autoPlay)
}

Player.prototype = Object.create(_globals.video.html5.backend.Player.prototype)

exports.createPlayer = function(ui) {
	return new Player(ui)
}

exports.probeUrl = function(url) {
	return 10
}

exports.Player = Player
