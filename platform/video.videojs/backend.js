var Player = function(ui) {
	var player = ui._context.createElement('video')
	player.dom.preload = "metadata"

	if (ui.autoPlay)
		player.setAttribute('autoplay')
	player.setAttribute('preload', 'auto')
	player.setAttribute('data-setup', '{}')
	player.setAttribute('class', 'video-js')

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
	player.on('canplaythrough', function() { log("ready to play"); if (ui.autoPlay) dom.play() }.bind(ui))

	player.on('error', function() {
		log("Player error occured")
		ui.error(dom.error)

		if (!dom.error)
			return

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
		ui.ready = false
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

	var uniqueId = 'videojs' + this.element._uniqueId
	player.setAttribute('id', uniqueId)

	ui.element.remove()
	ui.element = player
	ui.parent.element.append(ui.element)

	this.videojs = window.videojs(uniqueId)
	this.videojs.width = 'auto'
	this.videojs.height = 'auto'

	var errorDisplay = document.getElementsByClassName("vjs-error-display")
	if (errorDisplay && errorDisplay.length)
		errorDisplay[0].style.display = 'none'

	var videojsSpinner = document.getElementsByClassName("vjs-loading-spinner")
	if (videojsSpinner && videojsSpinner.length)
		videojsSpinner[0].style.display = 'none'

	this.videojsContaner = document.getElementById(uniqueId)
	this.videojsContaner.style.zindex = -1
}

Player.prototype = Object.create(_globals.video.html5.backend.Player.prototype)

Player.prototype.setSource = function(url) {
	var media = { 'src': url }
	log("SetSource", url)
	if (url) {
		var urlLower = url.toLowerCase()
		var querryIndex = url.indexOf("?")
		if (querryIndex >= 0)
			urlLower = urlLower.substring(0, querryIndex)
		var extIndex = urlLower.lastIndexOf(".")
		var extension = urlLower.substring(extIndex, urlLower.length - 1)
		if (extension == ".m3u8" || extension == ".m3u")
			media.type = 'application/x-mpegURL'
		else if (extension == ".mpd")
			media.type = 'application/dash+xml'
	}
	this.videojs.src(media, { html5: { hls: { withCredentials: true } }, fluid: true, preload: 'none', techOrder: ["html5"] })
}

Player.prototype.play = function() {
	var playPromise = this.element.dom.play()
	if (playPromise !== undefined) {
		playPromise.catch(function(e) {
			log('play error:', e)
			if (this.ui.autoPlay && e.code == DOMException.ABORT_ERR)
				this.element.dom.play()
		}.bind(this))
	}
}

Player.prototype.setRect = function(l, t, r, b) {
	this.videojsContaner.style.width = (r - l) + "px"
	this.videojsContaner.style.height = (b - t) + "px"
}

exports.createPlayer = function(ui) {
	return new Player(ui)
}

exports.probeUrl = function(url) {
	return window.videojs ? 60 : 0
}
