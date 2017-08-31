///container item for videos
Item {
	signal error;		///< error occured signal
	signal finished;	///< video finished signal
	property string	source;	///< video source URL
	property Color	backgroundColor: "#000";	///< default background color
	property float	volume: 1.0;		///< video volume value [0:1]
	property bool	loop;		///< video loop flag
	property bool	flash;		///< use flash flag
	property bool	ready;		///< read only property becomes 'true' when video is ready to play, 'false' otherwise
	property bool	muted;		///< volume mute flag
	property bool	paused;		///< video paused flag
	property bool	waiting;	///< wating flag while video is seeking and not ready to continue playing
	property bool	seeking;	///< seeking flag
	property bool	autoPlay;	///< play video immediately after source changed
	property int	duration;	///< content duration in seconds (valid only for not live videos)
	property int	progress;	///< current playback progress in seconds
	property int	buffered;	///< buffered contetnt in seconds

	LocalStorage { id: volumeStorage; name: "volume"; }

	onLoopChanged: { this.element.dom.loop = value }
	onBackgroundColorChanged: { if (!this.flash) this.element.dom.style.backgroundColor = value }

	///@private
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

	///play video
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

	/**@param value:int seek time in seconds
	seek video on 'value' seconds respectivly current playback progress*/
	seek(value): {
		if (!this.flash) {
			this.element.dom.currentTime += value
		} else {
			var player = this.parent.getFlashMovieObject('videoPlayer')
			player.playerSeek(player.getPosition() + value)
		}
	}

	/**@param value:int progress time in seconds
	set video progres to fixed second*/
	seekTo(value): {
		if (!this.flash) {
			this.element.dom.currentTime = value
		} else {
			var player = this.parent.getFlashMovieObject('videoPlayer')
			player.playerSeek(value)
		}
	}

	///@private
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

	///@private
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

	///stop video
	stop: { this.pause() }

	///pause video
	pause: {
		if (!this.flash) {
			this.element.dom.pause()
		} else {
			var player = this.getFlashMovieObject('videoPlayer')
			if (player.playerPlay)
				player.playerPlay(-1)
		}
	}

	///increase current volume
	volumeUp:			{ this.volume += 0.1 }

	///decrease current volume
	volumeDown:			{ this.volume -= 0.1 }

	///toggle volume mute on\off
	toggleMute:			{ this.element.dom.muted = !this.element.dom.muted }

	///@private
	onVolumeChanged:	{ this.applyVolume() }

	///@private
	onReadyChanged:		{ log("ReadyState: " + this.ready) }

	///@private
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

	///@private
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

	///@private
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

	///@private
	onWidthChanged: {
		if (!this.flash)
			return

		this.element.dom.setAttribute("width", this.width)
		var player = this.getFlashMovieObject('videoPlayer')
		player.setAttribute("width", this.width)
	}

	///@private
	onHeightChanged: {
		if (!this.flash)
			return

		this.element.dom.setAttribute("height", this.height)
		var player = this.getFlashMovieObject('videoPlayer')
		player.setAttribute("height", this.height)
	}

	///@private
	onCompleted: {
		if (this.autoPlay && this.source)
			this.play()

		volumeStorage.read()
		this.volume = volumeStorage.value ? +(volumeStorage.value) : 1.0

		if (!this.flash)
			this.element.dom.style.backgroundColor = this.backgroundColor;
	}
}
