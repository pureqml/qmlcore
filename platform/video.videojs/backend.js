var Player = function(ui) {
	var player = ui._context.createElement('video')
	player.dom.preload = "metadata"

	player.setAttribute('preload', 'auto')
	player.setAttribute('data-setup', '{}')
	player.setAttribute('class', 'video-js')

	this.element = player
	this.ui = ui
	this.setEventListeners()

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
		var extension = urlLower.substring(extIndex, urlLower.length)
		if (extension === ".m3u8" || extension === ".m3u")
			media.type = 'application/x-mpegURL'
		else if (extension === ".mpd")
			media.type = 'application/dash+xml'
	}
	this.videojs.src(media, { html5: { hls: { withCredentials: true } }, fluid: true, preload: 'none', techOrder: ["html5"] })
}

Player.prototype.play = function() {
	var playPromise = this.element.dom.play()
	if (playPromise !== undefined) {
		playPromise.catch(function(e) {
			log('play error:', e)
			if (this.ui.autoPlay && e.code === DOMException.ABORT_ERR)
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
