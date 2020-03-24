var Player = function(ui) {
	var player = ui._context.createElement('video')
	this.element = player
	this.ui = ui
	this.setEventListeners()
	this.element.style("pointer-events", "none")

	ui.element.remove()
	ui.element = player
	ui.parent.element.append(ui.element)
}

Player.prototype = Object.create(_globals.video.html5.backend.Player.prototype)
