Item {
	signal error;
	signal finished;
	property string	source;
	property Color	backgroundColor: "#000";
	property float	volume: 1.0;
	property bool	loop: false;
	property bool	ready: false;
	property bool	muted: false;
	property bool	paused: false;
	property bool	autoPlay: false;
	property bool	waiting: false;
	property bool	seeking: false;
	property int	duration;
	property int	progress;
	property int	buffered;

	LocalStorage { id: volumeStorage; name: "volume"; }

	function _update(name, value) {
		switch (name) {
			case 'loop': this.element.dom.loop = value; break
			case 'backgroundColor': this.element.dom.style.backgroundColor = value; break
		}

		qml.core.Item.prototype._update.apply(this, arguments);
	}

	play: {
		if (!this.source)
			return

		log("play", this.source)
		this.element.dom.play()

		this.applyVolume();
	}

	seek(value): {
		this.element.dom.currentTime += value
	}

	seekTo(value): {
		this.element.dom.currentTime = value
	}

	onAutoPlayChanged: {
		if (value)
			this.play()
	}

	applyVolume: {
		if (this.volume > 1.0)
			this.volume = 1.0;
		else if (this.volume < 0.0)
			this.volume = 0.0;

		volumeStorage.value = this.volume
		this.element.dom.volume = this.volume
	}

	stop: { this.pause() }

	pause: {
		this.element.dom.pause()
	}

	volumeUp:			{ this.volume += 0.1 }
	volumeDown:			{ this.volume -= 0.1 }
	toggleMute:			{ this.element.dom.muted = !this.element.dom.muted }
	onVolumeChanged:	{ this.applyVolume() }
	onReadyChanged:		{ log("ReadyState: " + this.ready) }

	onError: {
		this.paused = false
		this.waiting = false
		var player = this.player

		if (!player || !player.error)
			return

		log("player.error", player.error)
		if (player.error.code) {
			switch (player.error.code) {
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
		}
	}

	constructor: {
		this.player = this._context.createElement('video')
		var player = this.player
		player.dom.preload = "metadata"

		var dom = player.dom
		var self = this
		player.on('play', function() { self.waiting = false; self.paused = dom.paused; self.ready = dom.readyState }.bind(this))
		player.on('error', function() { log("Player error occured"); self.error() }.bind(this))
		player.on('pause', function() { self.paused = dom.paused }.bind(this))
		player.on('ended', function() { self.finished() }.bind(this))
		player.on('seeked', function() { log("seeked"); self.seeking = false; self.waiting = false }.bind(this))
		player.on('canplay', function() { log("canplay", dom.readyState); self.ready = dom.readyState }.bind(this))
		player.on('seeking', function() { log("seeking"); self.seeking = true; self.waiting = true }.bind(this))
		player.on('waiting', function() { log("waiting"); self.waiting = true }.bind(this))
		player.on('stolled', function() { log("Was stolled", dom.networkState); }.bind(this))
		player.on('emptied', function() { log("Was emptied", dom.networkState); }.bind(this))
		player.on('volumechange', function() { self.muted = dom.muted }.bind(this))
		player.on('canplaythrough', function() { log("Canplaythrough"); }.bind(this))

		player.on('timeupdate', function() {
			self.waiting = false
			if (!self.seeking)
				self.progress = dom.currentTime
		}.bind(this))

		player.on('durationchange', function() {
			var d = dom.duration
			self.duration = isFinite(d) ? d : 0
			self.progress = dom.currentTime
		}.bind(this))

		player.on('progress', function() {
			var last = dom.buffered.length - 1
			self.waiting = false
			if (last >= 0)
				self.buffered = dom.buffered.end(last) - dom.buffered.start(last)
		}.bind(this))

		this.element.remove()
		this.element = player
		this.parent.element.append(this.element)
	}

	onSourceChanged: {
		this.element.dom.src = value
		if (this.autoPlay)
			this.play()
	}

	onCompleted: {
		if (this.autoPlay && this.source)
			this.play()

		volumeStorage.read()
		this.volume = volumeStorage.value ? +(volumeStorage.value) : 1.0
		this.player.dom.style.backgroundColor = this.backgroundColor;
	}
}
