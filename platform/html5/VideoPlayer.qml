Item {
	signal finished;
	signal error;
	property bool	autoPlay;
	property string	source;
	property bool	loop: false;
	property bool	flash : true;
	property bool	ready : false;
	property bool	paused: false;
	property bool	muted: false;
	property bool	flasPlayerPaused: false;
	property bool	waiting: false;
	property bool	seeking: false;
	property float	volume: 1.0;
	property int	duration;
	property int	progress;
	property int	buffered;

	LocalStorage { id: volumeStorage; name: "volume"; }

	play: {
		if (!this.source)
			return

		log("play", this.source)
		if (this.flash) {
			var player = this.getObject('videoPlayer')
			if (!player || !player.playerLoad) //flash player is not ready yet
				return
			if (this.flasPlayerPaused) {
				player.playerPlay()
			} else {
				player.playerLoad(this.source)
				player.playerPlay(-1)
			}
			this.flasPlayerPaused = false
		} else {
			this._player.get(0).play()
		}

		this.applyVolume();
	}

	seek(value): {
		if (!this.flash)
			this._player.get(0).currentTime += value
		//TODO: Impl for flash player.
	}

	seekTo(value): {
		if (!this.flash)
			this._player.get(0).currentTime = value
		//TODO: Impl for flash player.
	}

	onAutoPlayChanged: {
		if (value)
			this.play()
	}

	onSourceChanged: {
		var source = this.source
		log("source changed to", source)
		if (!this.flash) {
			this._player.attr('src', this.source)
		}
		if (this.autoPlay)
			this.play()
	}

	onWidthChanged: {
		if (!this._player)
			return;

		if (this.flash) {
			$('#videoPlayer').attr('width', value)
			$('embed[name=videoPlayer]').attr('width', value)
		} else
			this._player.attr('width', this.width)
	}

	onHeightChanged: {
		if (!this._player)
			return;
		if (this.flash) {
			$('#videoPlayer').attr('height', value)
			$('embed[name=videoPlayer]').attr('height', value)
		} else
			this._player.attr('height', this.height)
	}

	onLoopChanged: { if (this._player) this._player.attr('loop', this.loop) }

	onCompleted: {
		if (navigator.userAgent.indexOf('Android') >= 0 || navigator.userAgent.indexOf('iPhone') >= 0)
			//navigator.userAgent.indexOf('Chromium'))
			this.flash = false

		if (!this.flash) {
			this._player = $('<video preload="metadata" width="' + this.width +
				'" height="' + this.height +
				'" src="' + this.src +
				'" autoplay=' + (this.autoPlay? "autoplay": "") +
				'>')
			this._player.css('background-color', 'black')
			this._player.attr('loop', this.loop)

			var player = this._player.get(0)
			var self = this
			player.addEventListener('error', function () { log("Player error occured"); self.error() })
			player.addEventListener('play', function () { self.waiting = false; self.paused = player.paused })
			player.addEventListener('pause', function () { self.paused = player.paused })
			player.addEventListener('ended', function () { self.finished() })
			player.addEventListener('seeked', function () { log("seeked"); self.seeking = false; self.waiting = false })
			player.addEventListener('canplay', function () { log("canplay", player.readyState); self.ready = player.readyState })
			player.addEventListener('seeking', function () { log("seeking"); self.seeking = true; self.waiting = true })
			player.addEventListener('waiting', function () { log("waiting"); self.waiting = true })
			player.addEventListener('volumechange', function () { self.muted = player.muted })
			player.addEventListener('stolled', function () { log("Was stolled", player.networkState); })
			player.addEventListener('emptied', function () { log("Was emptied", player.networkState); })
			player.addEventListener('canplaythrough', function () { log("Canplaythrough"); })

			player.addEventListener('timeupdate', function () {
				self.waiting = false
				if (!self.seeking)
					self.progress = player.currentTime
			})

			player.addEventListener('durationchange', function () {
				var d = player.duration
				self.duration = isFinite(d) ? d : 0
			})

			player.addEventListener('progress', function () {
				var last = player.buffered.length - 1
				self.waiting = false
				if (last >= 0)
					self.buffered = player.buffered.end(last) - player.buffered.start(last)
			})
		} else {
			console.log("creating object")
			this._player = $(
				'<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="" id="videoPlayer" width="' + this.width + '" height="' + this.height + '">' +
				'<param name="movie"  value="flashlsChromeless.swf?inline=1" />' +
				'<param name="quality" value="autohigh" />' +
				'<param name="swliveconnect" value="true" />' +
				'<param name="allowScriptAccess" value="sameDomain" />' +
				'<param name="bgcolor" value="#0" />' +
				'<param name="allowFullScreen" value="true" />' +
				'<param name="wmode" value="window" />' +
				'<embed src="flashlsChromeless.swf?inline=1" width="' + this.width + '" height="' + this.height + '" name="videoPlayer" quality="autohigh" bgcolor="#0" align="middle" allowFullScreen="true" allowScriptAccess="sameDomain" type="application/x-shockwave-flash" swliveconnect="true" wmode="window" pluginspage="http://www.macromedia.com/go/getflashplayer"> </embed>' +
				'</object>'
			)
		}
		this.element.append(this._player)
		if (this.autoPlay)
			this.play()

		volumeStorage.read();

		this.volume = volumeStorage.value ? +(volumeStorage.value) : 1.0;
	}

	Timer {
		interval: 500;
		repeat: true;
		running: true;

		onTriggered: {
			this.parent.duration = this.parent._player.get(0).duration ? this.parent._player.get(0).duration : 0
			this.parent.muted = this.parent._player.get(0).muted
			this.parent.ready = this.parent._player.get(0).readyState || this.parent.flash;	//TODO: temporary fix.
			this.parent.paused = this.parent.ready && (this.parent._player.get(0).paused || this.parent.flasPlayerPaused);
		}
	}

	Timer {
		interval: 100;
		repeat: true;
		running: true; //fixme: rewrite as 'parent.flash && !parent.flashReady'

		onTriggered: {
			var parent = this.parent
			if (!parent.flash)
				return

			var player = parent.getObject('videoPlayer')
			if (player && player.playerLoad) {
				console.log("flash player is ready")
				this.running = false;
				if (parent.autoPlay)
					parent.play()
			}
		}
	}

	getObject(name): {
		if (window.document[name])
			return window.document[name];
		if (navigator.appName.indexOf("Microsoft Internet")==-1) {
			if (document.embeds && document.embeds[name])
				return document.embeds[name];
		} else
			return document.getElementById(name)
	}

	applyVolume: {
		if (this.volume > 1.0)
			this.volume = 1.0;
		else if (this.volume < 0.0)
			this.volume = 0.0;

		volumeStorage.value = this.volume

		if (this.flash) {
			var player = this.getObject('videoPlayer')
			if (!player || !player.playerLoad)
				return
			player.playerVolume(100 * this.volume)
		} else if (this._player) {
			this._player.get(0).volume = this.volume
		}
	}

	pause: {
		if (this.flash) {
			var player = this.getObject('videoPlayer')
			if (!player || !player.playerLoad)
				return
			player.playerPause()
			this.flasPlayerPaused = true
		} else if (this._player) {
			this._player.get(0).pause()
		}
	}

	volumeUp:			{ this.volume += 0.1; }
	volumeDown:			{ this.volume -= 0.1; }
	toggleMute:			{ this._player.get(0).muted = !this._player.get(0).muted }
	onVolumeChanged:	{ this.applyVolume(); }
	onReadyChanged:		{ log("ReadyState: " + this.ready); }

	onError: {
		this.paused = false
		this.waiting = false
		var player = this._player.get(0)

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
}
