var Player = function(ui) {
	var player = ui._context.createElement('video')
	player.dom.preload = "metadata"

	this.element = player
	this.ui = ui
	this.setEventListeners()

	ui.element.remove()
	ui.element = player
	ui.parent.element.append(ui.element)

	this._xhr = new XMLHttpRequest()
	this._xhr.addEventListener('load', ui._context.wrapNativeCallback(this.parseManifest).bind(this))
}

Player.prototype.dispose = function() {
	var ui = this.ui
	if (!ui)
		return

	var element = ui.element
	if (element) {
		element.remove()
		ui.element = null
	}
}

Player.prototype.setEventListeners = function() {
	var player = this.element
	var dom = player.dom
	var ui = this.ui
	player.on('play', function() { ui.waiting = false; ui.paused = dom.paused }.bind(ui))
	player.on('pause', function() { ui.paused = dom.paused }.bind(ui))
	player.on('ended', function() { ui.finished() }.bind(ui))
	player.on('seeked', function() { log("seeked"); ui.seeking = false; ui.waiting = false }.bind(ui))
	player.on('canplay', function() { log("canplay", dom.readyState); ui.ready = dom.readyState }.bind(ui))
	player.on('seeking', function() { log("seeking"); ui.seeking = true; ui.waiting = true }.bind(ui))
	player.on('waiting', function() { log("waiting"); ui.waiting = true }.bind(ui))
	player.on('stalled', function() { log("Was stalled", dom.networkState); ui.stalled = true }.bind(ui))
	player.on('emptied', function() { log("Was emptied", dom.networkState); }.bind(ui))
	player.on('volumechange', function() { ui.muted = dom.muted }.bind(ui))
	player.on('canplaythrough', function() { log("ready to play"); ui.paused = dom.paused }.bind(ui))
	player.on('suspend', function() { log('suspended') })

	player.on('error', function() {
		log("Player error occurred", dom.error, "src", ui.source)

		if (!dom.error || !ui.source)
			return

		ui.error(dom.error)

		log("player.error", dom.error)
		switch (dom.error.code) {
		case 1:
			log("MEDIA_ERR_ABORTED error occurred")
			break;
		case 2:
			log("MEDIA_ERR_NETWORK error occurred")
			break;
		case 3:
			log("MEDIA_ERR_DECODE error occurred")
			break;
		case 4:
			log("MEDIA_ERR_SRC_NOT_SUPPORTED error occurred")
			break;
		default:
			log("UNDEFINED error occurred")
			break;
		}
	}.bind(ui))

	player.on('timeupdate', function() {
		ui.waiting = false
		ui.stalled = false
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

	this.setOption("autoplay", ui.autoPlay)
}

Player.prototype.parseManifest = function(data) {
	var lines = data.target.responseText.split('\n');
	var url = this.ui.source
	var path = url.substring(0, url.lastIndexOf('/') + 1)
	var idx = 0
	this._videoTracks = [ { "name": "auto", "url": this.ui.source, "id": idx } ]
	this._totalTracks = {}
	this._audioTracksInfo = []
	for (var i = 0; i < lines.length - 1; ++i) {
		var line = lines[i]
		var nextLine = lines[i + 1]
		if (line.indexOf('#EXT-X-STREAM-INF') == 0) {
			var attributes = line.split(',');
			var track = {
				url: nextLine.indexOf("http") === 0 ? nextLine : (path + nextLine)
			}
			for (var j = 0; j < attributes.length; ++j) {
				var param = attributes[j].split('=');
				if (param.length > 1) {
					switch (param[0].trim().toLowerCase()) {
						case "bandwidth":
							track.bandwidth = param[1].trim()
							break
						case "audio":
							track.audio = param[1].trim().replace(/"/g, "")
							break
						case "resolution":
							var size = param[1].split("x")
							track.width = size[0]
							track.height = size[1]
							break
					}
				}
			}
			var key = track.width + "x" + track.height
			if (!this._totalTracks[key]) {
				this._totalTracks[key] = []
			}
			this._totalTracks[key].push(track)
		} else if (line.indexOf('#EXT-X-MEDIA:TYPE=AUDIO') == 0) {
			var attributes = line.split(',');
			var audioTrack = {}
			for (var j = 0; j < attributes.length; ++j) {
				var param = attributes[j].split('=');
				if (param.length > 1) {
					switch (param[0].trim().toLowerCase()) {
						case "group-id":
							audioTrack.id = param[1].trim().replace(/"/g, "")
							break
						case "name":
							audioTrack.label = param[1].trim().replace(/"/g, "")
							break
						case "language":
							audioTrack.language = param[1].trim().replace(/"/g, "")
							break
						case "uri":
							audioTrack.url = param[1].trim()
							break
					}
				}
			}
			this._audioTracksInfo.push(audioTrack)
		}
	}

	for (var i in this._totalTracks) {
		var tmpTrack = this._totalTracks[i][0]
		tmpTrack.id = ++idx
		this._videoTracks.push(tmpTrack)
	}
}

Player.prototype.getFileExtension = function(filePath) {
	if (!filePath)
		return ""
	var urlLower = filePath.toLowerCase()
	var querryIndex = filePath.indexOf("?")
	if (querryIndex >= 0)
		urlLower = urlLower.substring(0, querryIndex)
	var extIndex = urlLower.lastIndexOf(".")
	return urlLower.substring(extIndex, urlLower.length)
}

Player.prototype.setSource = function(url) {
	this.ui.ready = false
	this._extension = this.getFileExtension(url)
	if (url && this._xhr && (this._extension === ".m3u8" || this._extension === ".m3u")) {
		this._xhr.open('GET', url);
		this._xhr.send()
	}

	var source = url
	if (this.ui.startPosition)
		source += "#t=" + this.ui.startPosition
	this.element.dom.src = source
}

Player.prototype.play = function() {
	this.element.dom.play()
}

Player.prototype.pause = function() {
	this.element.dom.pause()
}

Player.prototype.stop = function() {
	//where is no 'stop' method in html5 video player just pause instead
	this.pause()
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

Player.prototype.setOption = function(name, value) {
	if (name === "autoplay") {
		if (value)
			this.element.dom.setAttribute("autoplay", "")
		else
			this.element.dom.removeAttribute("autoplay");
	} else {
		this.element.dom.setAttribute(name, value)
	}
}

Player.prototype.setRect = function(l, t, r, b) {
	//not needed in this port
}

Player.prototype.setVisibility = function(visible) {
	log('VISIBILITY LOGIC MISSING HERE, visible:', visible)
}

Player.prototype.setupDrm = function(type, options, callback, error) {
	log('Not implemented')
}

Player.prototype.getSubtitles = function() {
	var textTracks = this.element.dom.textTracks
	var result = []
	for (var i = 0; i < textTracks.length; ++i) {
		var track = textTracks[i]
		result.push({
			"id": track.id,
			"label": track.label,
			"language": track.language
		})
	}
	return result
}

Player.prototype.getVideoTracks = function() {
	return this._videoTracks || []
}

Player.prototype.getAudioTracks = function() {
	var audioTracks = this.element.dom.audioTracks || []
	var result = []
	for (var i = 0; i < audioTracks.length; ++i) {
		var track = audioTracks[i]
		var info = this._audioTracksInfo[i]
		result.push({
			"id": i,
			"name": track.label ? track.label : info.name,
			"language": track.language ? track.language : info.language
		})
	}
	log("getAudioTracks", result)
	return result
}

Player.prototype.setAudioTrack = function(trackId) {
	var audioTracks = this.element.dom.audioTracks
	if (trackId < 0 || trackId >= audioTracks.length) {
		log("Where is no track", trackId)
		return
	}
	log("Set audio track", audioTracks[trackId])

	var result = []
	for (var i = 0; i < audioTracks.length; ++i)
		audioTracks[i].enabled = i === trackId
}

Player.prototype.setVideoTrack = function(trackId) {
	if (!this._videoTracks || this._videoTracks.length <= 0) {
		log("There is no available video track", this._videoTracks)
		return
	}
	if (trackId < 0 || trackId >= this._videoTracks.length) {
		log("Track with id", trackId, "not found")
		return
	}
	this.ui.waiting = true
	var progress = this.ui.progress
	log("Set video", this._videoTracks[trackId])
	this.element.dom.src = this._videoTracks[trackId].url
	this.seekTo(progress)
}

Player.prototype.setVideoTrack = function(trackId) {
	if (!this._videoTracks || this._videoTracks.length <= 0) {
		log("There is no available video track", this._videoTracks)
		return
	}
	if (trackId < 0 || trackId >= this._videoTracks.length) {
		log("Track with id", trackId, "not found")
		return
	}
	this.ui.waiting = true
	var progress = this.ui.progress
	log("Set video", this._videoTracks[trackId])
	this.element.dom.src = this._videoTracks[trackId].url
	this.seekTo(progress)
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
