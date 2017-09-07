var Player = function(ui) {
	//TODO: it's just a copy of
	var player = ui._context.createElement('video')
	player.dom.preload = "metadata"

	var dom = player.dom
	player.on('play', function() { ui.waiting = false; ui.paused = dom.paused }.bind(ui))
	player.on('error', function() { log("Player error occured"); ui.error() }.bind(ui))
	player.on('pause', function() { ui.paused = dom.paused }.bind(ui))
	player.on('ended', function() { ui.finished() }.bind(ui))
	player.on('seeked', function() { log("seeked"); ui.seeking = false; ui.waiting = false }.bind(ui))
	player.on('canplay', function() { log("canplay", dom.readyState); ui.ready = dom.readyState }.bind(ui))
	player.on('seeking', function() { log("seeking"); ui.seeking = true; ui.waiting = true }.bind(ui))
	player.on('waiting', function() { log("waiting"); ui.waiting = true }.bind(ui))
	player.on('stalled', function() { log("Was stalled", dom.networkState); }.bind(ui))
	player.on('emptied', function() { log("Was emptied", dom.networkState); }.bind(ui))
	player.on('volumechange', function() { ui.muted = dom.muted }.bind(ui))
	player.on('canplaythrough', function() { log("ready to play"); }.bind(ui))

	player.on('timeupdate', function() {
		ui.waiting = false
		if (!ui.seeking)
			ui.progress = dom.currentTime
	}.bind(ui))

	player.on('durationchange', function() {
		var d = dom.duration
		ui.duration = isFinite(d) ? d : 0
	}.bind(ui))

	player.on('progress', function() {
		var last = dom.buffered.length - 1
		ui.waiting = false
		if (last >= 0)
			ui.buffered = dom.buffered.end(last) - dom.buffered.start(last)
	}.bind(ui))

	this.element = player

	ui.element.remove()
	ui.element = player
	ui.parent.element.append(ui.element)
}

Player.prototype = Object.create(_globals.video.html5.backend.Player.prototype)

exports.createPlayer = function(ui) {
	return new Player(ui)
}

exports.probeUrl = function(url) {
	return 60
}

log("Back Player", Player, "proto", _globals.video.html5.backend.Player.prototype, "glo", _globals.video.videojs.backend)
