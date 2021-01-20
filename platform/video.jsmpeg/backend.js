var HlsSource = function(url, options) {
	log("source created ", url, options)
	this.url = url
	this.options = options
	this.context = options.qmlElement._context
	this.history = []
	this.queue = []
	this.destroyed = false
	this.progress = 0
	this.established = false
	this.completed = false
	this.streaming = true
	this.onEstablishedCallback = options.onSourceEstablished
}

HlsSource.prototype.reload = function() {
	if (!this.currentPlaylistUrl) {
		log("no current playlist")
		return
	}
	this.get(this.currentPlaylistUrl)
}

HlsSource.prototype.loadSegment = function() {
	if (this.destroyed)
		return

	if (this.queue.length > 0) {
		var next = this.queue.shift()
		log('loading...', next)
		this.getSegment(next)
	} else
		log("empty queue, underflowing")
}

HlsSource.prototype.done = function(data) {
	if (this.destroyed)
		return

	var target = data.target
	if (target.status >= 400) {
		this.error(data)
		return
	}
	var parser = new m3u8Parser.Parser()

	parser.push(target.responseText)
	parser.end()

	var firstEstablished = !this.established
	this.established = true
	if (this.onEstablishedCallback && firstEstablished)
		this.onEstablishedCallback(this)

	var manifest = parser.manifest
	log("loaded manifest", manifest)
	if (manifest.segments.length > 0) {
		log("loading segments")
		if (manifest.targetDuration) {
			setTimeout(this.reload.bind(this), manifest.targetDuration * 1000)
		}
		var queue = this.queue
		var history = this.history
		var segments = manifest.segments
		segments.forEach(function(segment) {
			var uri = segment.uri
			if (history.indexOf(uri) < 0) {
				log('scheduling segment', uri)
				queue.push(uri)
				history.push(uri)
			}
		})
		var maxHistory = segments.length * 3
		if (history.length > maxHistory) {
			history.splice(0, history.length - maxHistory)
		}
		this.loadSegment()
	} else {
		log("master playlist, loading first playlist, fixme")
		if (manifest.playlists.length === 0) {
			log("no playlists, bailing out")
			return
		}
		this.currentPlaylistUrl = manifest.playlists[0].uri
		this.reload()
	}
}

HlsSource.prototype.doneSegment = function(data) {
	if (this.destroyed)
		return

	this.progress = 1
	var target = data.target
	if (target.status >= 400) {
		this.error(data)
		return
	}
	log("done segment", this.destination)
	if (this.destination) {
		var buffer = data.target.response
		this.destination.write(new Uint8Array(buffer))
		log("bits", this.destination.bits)
	}
	this.loadSegment()
}

HlsSource.prototype.error = function(response) {
	log('loading error', response)
	this.loadSegment() //try to keep up if segment disappeared
}

HlsSource.prototype.get = function(url) {
	var request = {url: url}
	request.done = this.context.wrapNativeCallback(this.done.bind(this))
	request.error = this.context.wrapNativeCallback(this.error.bind(this))
	this.context.backend.ajax(this, request)
}

HlsSource.prototype.getSegment = function(url) {
	var request = {url: url, responseType: 'arraybuffer'}
	request.done = this.context.wrapNativeCallback(this.doneSegment.bind(this))
	request.error = this.context.wrapNativeCallback(this.error.bind(this))
	this.context.backend.ajax(this, request)
}

HlsSource.prototype.connect = function(destination) {
	log("source connect", destination)
	this.destination = destination
}

HlsSource.prototype.destroy = function() {
	log("source destroy")
	this.destination = null
	this.destroyed = true
}

HlsSource.prototype.start = function(time) {
	log("source start at ", time)
	this.get(this.url)
}

HlsSource.prototype.resume = function() {
	log("source resume")
}

var Player = function(ui) {
	this.ui = ui
	this.player = null
	this.volume = 1
	this.source = ''
	this.playing = false
	if (ui.element)
		ui.element.remove()

	ui.element = ui._context.createElement('canvas')
	ui.parent.element.append(ui.element)
}

Player.prototype.dispose = function() {
	if (this.player) {
		this.player.destroy()
		this.player = null
	}
}

Player.prototype.setRect = function(l, t, r, b) {
	this.ui.element.style({width: r - l, height: b - t})
}

Player.prototype.setVisibility = function(visible) {
	this.ui.element.style('visibility', visible? 'inherit': 'hidden')
}

Player.prototype.setVolume = function(volume) {
	this.volume = volume
}

Player.prototype._updateState = function() {
	if (this.playing && this.source) {
		if (!this.player) {
			log("creating player...")
			this.player = new JSMpeg.Player(this.source, {
				qmlElement: this.ui,
				source: HlsSource,
				autoplay: this.ui.autoplay,
				canvas: this.ui.element.dom
			})
		}
	} else {
		this.dispose()
	}
}

Player.prototype.setSource = function(url) {
	this.dispose()
	this.source = url
	if (this.ui.autoplay)
		this.playing = true
	this._updateState()
}

Player.prototype.setBackgroundColor = function(color) {
	log("player sets bg color to " + color)
}

Player.prototype.play = function() {
	log("msjpeg play")
	this.playing = true
	this._updateState()
}

Player.prototype.stop = function() {
	log("msjpeg stop")
	this.playing = false
	this._updateState()
}

exports.createPlayer = function(ui) {
	return new Player(ui)
}

exports.probeUrl = function(url) {
	return -100
}

exports.Player = Player
