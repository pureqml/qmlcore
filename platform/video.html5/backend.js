var Player = function(ui) {
	var player = ui._context.createElement('video')
	player.dom.preload = "metadata"

	var dom = player.dom
	player.on('play', function() { ui.waiting = false; ui.paused = dom.paused }.bind(ui))
	player.on('pause', function() { ui.paused = dom.paused }.bind(ui))
	player.on('ended', function() { ui.finished() }.bind(ui))
	player.on('seeked', function() { log("seeked"); ui.seeking = false; ui.waiting = false }.bind(ui))
	player.on('canplay', function() { log("canplay", dom.readyState); ui.ready = dom.readyState }.bind(ui))
	player.on('seeking', function() { log("seeking"); ui.seeking = true; ui.waiting = true }.bind(ui))
	player.on('waiting', function() { log("waiting"); ui.waiting = true }.bind(ui))
	player.on('stalled', function() { log("Was stalled", dom.networkState); }.bind(ui))
	player.on('emptied', function() { log("Was emptied", dom.networkState); }.bind(ui))
	player.on('volumechange', function() { ui.muted = dom.muted }.bind(ui))
	player.on('canplaythrough', function() { log("ready to play"); ui.paused = dom.paused }.bind(ui))

	player.on('error', function() {
		log("Player error occured", dom.error, "src", ui.source)

		if (!dom.error || !ui.source)
			return

		ui.error(dom.error)

		log("player.error", dom.error)
		switch (dom.error.code) {
		case 1:
			log("MEDIA_ERR_ABORTED error occured")
			break;
		case 2:
			log("MEDIA_ERR_NETWORK error occured")
			break;
		case 3:
			log("MEDIA_ERR_DECODE error occured")
			break;
		case 4:
			log("MEDIA_ERR_SRC_NOT_SUPPORTED error occured")
			break;
		default:
			log("UNDEFINED error occured")
			break;
		}
	}.bind(ui))

	player.on('timeupdate', function() {
		ui.waiting = false
		if (!ui.seeking)
			ui.progress = dom.currentTime
	}.bind(ui))

	player.on('durationchange', function() {
		var d = dom.duration
		log("Duration", d)
		ui.duration = isFinite(d) ? d : 0
	}.bind(ui))

	player.on('progress', function() {
		var last = dom.buffered.length - 1
		ui.waiting = false
		if (last >= 0)
			ui.buffered = dom.buffered.end(last) - dom.buffered.start(last)
	}.bind(ui))

	this.element = player
	this.ui = ui

	ui.element.remove()
	ui.element = player
	ui.parent.element.append(ui.element)
}

Player.prototype.setSource = function(url) {
	this.ui.ready = false
	this.element.dom.src = url
}

Player.prototype.play = function() {
	this.element.dom.play()
}

Player.prototype.pause = function() {
	this.element.dom.pause()
}

Player.prototype.seek = function(delta) {
	this.element.dom.currentTime += delta
}

Player.prototype.seekTo = function(tp) {
	this.element.dom.currentTime = tp
}

Player.prototype.setVolume = function(volume) {
	this.element.dom.volume = volume
}

Player.prototype.setMute = function(muted) {
	this.element.dom.muted = muted
}

Player.prototype.setLoop = function(loop) {
	this.element.dom.loop = loop
}

Player.prototype.setRect = function(l, t, r, b) {
	//not needed in this port
}

Player.prototype.setVisibility = function(visible) {
	log('VISIBILITY LOGIC MISSING HERE, visible:', visible)
}

Player.prototype.setBackgroundColor = function(color) {
	var Color = _globals.core.Color
	this.element.dom.style.backgroundColor = new Color(color).rgba()
}


exports.createPlayer = function(ui) {
	return new Player(ui)
}

exports.probeUrl = function(url) {
	return 50
}

exports.Player = Player
