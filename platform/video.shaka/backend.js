var Player = function(ui) {
	var player = ui._context.createElement('video')

	if (ui.autoPlay)
		player.setAttribute('autoplay', "")

	this._player = player

	shaka.polyfill.installAll();
	if (shaka.Player.isBrowserSupported()) {
		var shakaPlayer = new shaka.Player(player.dom);
		this.shakaPlayer = shakaPlayer;
		shakaPlayer.addEventListener('error', ui._context.wrapNativeCallback(function(err) { log("SHAKA PALER ERR", err) }));
	} else {
		console.error('Browser not supported!');
		return
	}

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
	this.setAutoPlay(ui.autoPlay)

	ui.element.remove()
	ui.element = player
	ui.parent.element.append(ui.element)
}

Player.prototype = Object.create(_globals.video.html5.backend.Player.prototype)

Player.prototype.setupDrm = function(type, options, callback, error) {
	var laServer = {}
	if (type === "widevine")
		laServer["com.widevine.alpha"] = options.laServer
	else if (type === "playready")
		laServer["com.microsoft.playready"] = options.laServer
	else
		error ? error(new Error("Unknown or not supported DRM type " + type)) : log("Unknown or not supported DRM type " + type)

	this.shakaPlayer.configure({ drm: { servers: laServer } });
	if (callback)
		callback()
}

Player.prototype.stop = function() {
	log("stop player")
	var self = this
	this.shakaPlayer.unload()
		.then(function(e) { log("Unloaded"); self.shakaPlayer.destroy(); self.shakaPlayer = new shaka.Player(self._player.dom); })
		.catch(function(e) { log("Unload failed", e); self.shakaPlayer.destroy(); self.shakaPlayer = new shaka.Player(self._player.dom); })
}

Player.prototype.setSource = function(url) {
	var ui = this.ui

	if (url) {
		var urlLower = url.toLowerCase()
		var querryIndex = url.indexOf("?")
		if (querryIndex >= 0)
			urlLower = urlLower.substring(0, querryIndex)
		var extIndex = urlLower.lastIndexOf(".")
		var extension = urlLower.substring(extIndex, urlLower.length)
		var player = this._player
		if (extension === ".mp4")
			this._player.dom.src = url
		else
			this.shakaPlayer.load(url)
				.then(function() { console.log('The video has now been loaded!'); })
				.catch(function(err) { log("Failed to load manifest") });
	}
}

exports.createPlayer = function(ui) {
	return new Player(ui)
}

exports.probeUrl = function(url) {
	return 150
}

exports.Player = Player
