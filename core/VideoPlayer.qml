///container item for videos
Item {
	property string backend; ///< backend to use

	signal error;		///< error occured signal
	signal finished;	///< video finished signal
	property string	source;	///< video source URL
	property Color	backgroundColor: "#000";	///< default background color
	property float	volume: 1.0;		///< video volume value [0:1]
	property bool	loop;		///< video loop flag
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
	onBackgroundColorChanged: { this.element.dom.style.backgroundColor = value }

	///play video
	play: {
		if (!this.source)
			return

		log("play", this.source)
		this.element.dom.play()
		this.applyVolume();
	}

	/**@param value:int seek time in seconds
	seek video on 'value' seconds respectivly current playback progress*/
	seek(value): {
		this.element.dom.currentTime += value
	}

	/**@param value:int progress time in seconds
	set video progres to fixed second*/
	seekTo(value): {
		this.element.dom.currentTime = value
	}

	///@private
	onAutoPlayChanged: {
		if (value)
			this.play()
	}

	///@private
	applyVolume: {
		if (this.volume > 1.0)
			this.volume = 1.0;
		else if (this.volume < 0.0)
			this.volume = 0.0;

		volumeStorage.value = this.volume
		this.element.dom.volume = this.volume
	}

	///stop video
	stop: { this.pause() }

	///pause video
	pause: {
		this.element.dom.pause()
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

	///@private
	constructor: {
		var player = context.createVideoPlayer()
		var player

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

		this.element.remove()
		this.element = player
		this.parent.element.append(this.element)
	}

	///@private
	onSourceChanged: {
		this.element.dom.src = value
		if (this.autoPlay)
			this.play()
	}

	///@private
	onWidthChanged: {
	}

	///@private
	onHeightChanged: {
	}

	///@private
	onCompleted: {
		if (this.autoPlay && this.source)
			this.play()

		volumeStorage.read()
		this.volume = volumeStorage.value ? +(volumeStorage.value) : 1.0

		this.element.dom.style.backgroundColor = this.backgroundColor;
	}
}
