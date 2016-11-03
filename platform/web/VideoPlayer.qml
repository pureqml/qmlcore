Item {
	signal finished;
	signal error;
	property string	source;
	property Color	backgroundColor: "#000";
	property float	volume: 1.0;
	property bool	loop: false;
	property bool	flash: true;
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

	//Timer {
		//interval: 500;
		//repeat: true;
		//running: true;

		//onTriggered: {
			//var player = this.parent.element.dom
			//this.parent.duration = player.duration ? this.parent._player.duration : 0
			//this.parent.muted = player.muted
			//this.parent.ready = player.readyState || this.parent.flash;	//TODO: temporary fix.
			//this.parent.paused = this.parent.ready && (player.paused || this.parent.flasPlayerPaused);
		//}
	//}

	function _update(name, value) {
		switch (name) {
			case 'loop': this.element.dom.loop = value; break
			case 'backgroundColor': if (!this.flash) this.element.dom.style.backgroundColor = value; break
		}

		qml.core.Item.prototype._update.apply(this, arguments);
	}

	getFlashMovieObject(movieName):
	{
		if (window.document[movieName])
			return window.document[movieName];
		if (navigator.appName.indexOf("Microsoft Internet")==-1)
			if (document.embeds && document.embeds[movieName])
				return document.embeds[movieName];
		else
			return document.getElementById(movieName);
	}

	play: {
		if (!this.source)
			return

		log("play", this.source)
		if (this.flash) {
			var player = this.getFlashMovieObject('videoPlayer')
			if (!player || !player.playerLoad) //flash player is not ready yet
				return

			player.playerPlay()
		} else {
			this.element.dom.play()
		}

		this.applyVolume();
	}

	seek(value): {
		if (!this.flash) {
			this.element.dom.currentTime += value
		} else {
			var player = parent.getFlashMovieObject('videoPlayer')
			player.playerSeek(player.getPosition() + value)
		}
	}

	seekTo(value): {
		if (!this.flash) {
			this.element.dom.currentTime = value
		} else {
			var player = parent.getFlashMovieObject('videoPlayer')
			player.playerSeek(value)
		}
	}

	onAutoPlayChanged: {
		if (value)
			this.play()
	}

	Timer {
		interval: 100;
		repeat: true;
		running: !parent.ready && parent.flash;

		onTriggered: {
			var parent = this.parent
			if (!parent.flash)
				return

			var player = parent.getFlashMovieObject('videoPlayer')
			if (player && player.playerLoad) {
				console.log("flash player is ready")
				player.playerLoad(parent.source)
				player.playerVolume(parent.volume * 100)
				if (parent.autoPlay)
					parent.play()
				parent.ready = true
			}
		}
	}

	applyVolume: {
		if (this.volume > 1.0)
			this.volume = 1.0;
		else if (this.volume < 0.0)
			this.volume = 0.0;

		volumeStorage.value = this.volume
		if (!this.flash) {
			this.element.dom.volume = this.volume
		} else {
			var player = this.getFlashMovieObject('videoPlayer')
			if (player.playerVolume)
				player.playerVolume(this.volume * 100)
		}
	}

	pause: {
		if (!this.flash) {
			this.element.dom.pause()
		} else {
			var player = this.getFlashMovieObject('videoPlayer')
			if (player.playerPlay)
				player.playerPlay(-1)
		}
	}

	volumeUp:			{ this.volume += 0.1 }
	volumeDown:			{ this.volume -= 0.1 }
	toggleMute:			{ this.element.dom.muted = !this.element.dom.muted }
	onVolumeChanged:	{ this.applyVolume() }
	onReadyChanged:		{ log("ReadyState: " + this.ready) }

	onError: {
		this.paused = false
		this.waiting = false
		var player = this.element.dom

		if (this.flash || !player || !player.error)
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
		if (_globals.core.device)	// 0 value for desktop
			this.flash = false

		log("Player:", this.flash)
		var player
		if (!this.flash) {
			player = this._context.createElement('video')
			player.dom.preload = "metadata"

			var dom = player.dom
			var self = this
			player.on('play', function() { self.waiting = false; self.paused = dom.paused }.bind(this))
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
			}.bind(this))

			player.on('progress', function() {
				var last = dom.buffered.length - 1
				self.waiting = false
				if (last >= 0)
					self.buffered = dom.buffered.end(last) - dom.buffered.start(last)
			}.bind(this))
		} else {
			player = this._context.createElement('object')
			player.dom.setAttribute("classid", "clsid:D27CDB6E-AE6D-11cf-96B8-444553540000")
			player.dom.setAttribute("id", "videoPlayer")
			player.dom.setAttribute("width", this.width)
			player.dom.setAttribute("height", this.height)
			player.setHtml(
				'<param name="movie"  value="./flashlsChromeless.swf?inline=1" />' +
				'<param name="quality" value="autohigh" />' +
				'<param name="swliveconnect" value="true" />' +
				'<param name="allowScriptAccess" value="sameDomain" />' +
				'<param name="bgcolor" value="#0" />' +
				'<param name="allowFullScreen" value="true" />' +
				'<param name="wmode" value="window" />' +
				'<param name="FlashVars" value="callback=flashlsCallback" />' +
				'<embed src="./flashlsChromeless.swf?inline=1" width="720" height="480" name="videoPlayer"' +
					'quality="autohigh"' +
					'bgcolor="#0"' +
					'align="middle" allowFullScreen="true"' +
					'allowScriptAccess="sameDomain"' +
					'type="application/x-shockwave-flash"' +
					'swliveconnect="true"' +
					'wmode="window"' +
					'FlashVars="callback=flashlsCallback"' +
					'pluginspage="http://www.macromedia.com/go/getflashplayer" >' +
				'</embed>'
			)
		}

		this.element.remove()
		this.element = player
		this.parent.element.append(this.element)
	}

	onSourceChanged: {
		if (!this.flash) {
			this.element.dom.src = value
		} else {
			var player = this.getFlashMovieObject('videoPlayer')
			if (player.playerLoad)
				player.playerLoad(value)
		}
		if (this.autoPlay)
			this.play()
	}

	onWidthChanged: {
		if (!this.flash)
			return

		this.element.dom.setAttribute("width", this.width)
		var player = this.getFlashMovieObject('videoPlayer')
		player.setAttribute("width", this.width)
	}

	onHeightChanged: {
		if (!this.flash)
			return

		this.element.dom.setAttribute("height", this.height)
		var player = this.getFlashMovieObject('videoPlayer')
		player.setAttribute("height", this.height)
	}

	onCompleted: {
		if (this.autoPlay && this.source)
			this.play()

		volumeStorage.read()
		this.volume = volumeStorage.value ? +(volumeStorage.value) : 1.0

		if (!this.flash)
			player.dom.style.backgroundColor = this.backgroundColor;
	}
}
