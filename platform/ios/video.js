var Player = function(ui) {
	var player = ui._context.createElement('video')
	this.element = player
	this.ui = ui
	this.setEventListeners()
	this.element.style("pointer-events", "none")
	this.element.dom.setAttribute("webkit-playsinline", "")
	this.element.dom.setAttribute("playsinline", "")

	ui.element.remove()
	ui.element = player
	ui.parent.element.append(ui.element)
}

Player.prototype = Object.create(_globals.video.html5.backend.Player.prototype)

exports.createPlayer = function(ui) {
	return new Player(ui)
}

exports.probeUrl = function(url) {
	return 150
}

exports.Player = Player
