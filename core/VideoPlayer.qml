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
	property int	duration;	///< content duration in seconds (only for non-live videos)
	property int	progress;	///< current playback progress in seconds
	property int	buffered;	///< how much content to buffer in seconds

	LocalStorage { id: volumeStorage; name: "volume"; }

	///@private
	constructor: {
		this.impl = null
	}

	function _getPlayer() {
		if (this.impl === null)
			this._createPlayer(this)
		return this.impl
	}

	function _createPlayer() {
		if (this.impl)
			return this.impl

		var source = this.source
		if (!source)
			return

		var preferred = this.backend
		log('preferred backend: ' + preferred)
		var backends = _globals.core.__videoBackends
		var results = []
		for(var i in backends) {
			var backend = backends[i]()
			var score = backend.probeUrl(source)
			if (score > 0)
				results.push({ backend: backend, score: score })
		}
		results.sort(function(a, b) { return b.score - a.score })
		if (results.length === 0)
			throw new Error('no backends for source ' + source)
		return this.impl = results[0].backend.createPlayer(this)
	}

	onLoopChanged: {
		var player = this._getPlayer()
		if (player)
			setLoop(value)
	}

	onBackgroundColorChanged: {
		var player = this._getPlayer()
		if (player)
			setBackgroundColor(value)
	}

	///play video
	play: {
		if (!this.source)
			return

		log("play", this.source)
		var player = this._getPlayer()
		if (player)
			player.play()
		this.applyVolume();
	}

	/**@param value:int seek time in seconds
	seek video on 'value' seconds respectivly current playback progress*/
	seek(value): {
		var player = this._getPlayer()
		if (player)
			player.seek(value)
	}

	/**@param value:int progress time in seconds
	set video progres to fixed second*/
	seekTo(value): {
		var player = this._getPlayer()
		if (player)
			player.seekTo(value)
	}

	///@private
	onAutoPlayChanged: {
		if (value) //fixme: and not currently playing
			this.play()
	}

	///@private
	applyVolume: {
		if (this.volume > 1.0)
			this.volume = 1.0;
		else if (this.volume < 0.0)
			this.volume = 0.0;

		volumeStorage.value = this.volume
		var player = this._getPlayer()
		if (player)
			player.setVolume(this.volume)
	}

	///@private
	function _scheduleLayout() {
		this._context.delayedAction('layout', this, this._doLayout)
	}

	///@private
	function _doLayout() {
		var player = this._getPlayer()
		if (player)
			player.setRect.apply(player, this.toScreen())
	}

	///stop video
	stop: { this.pause() }

	///pause video
	pause: {
		var player = this._getPlayer()
		if (player)
			player.pause()
	}

	///increase current volume
	volumeUp:			{ this.volume += 0.1 }

	///decrease current volume
	volumeDown:			{ this.volume -= 0.1 }

	///toggle volume mute on\off
	toggleMute:			{ var player = this._getPlayer(); if (player) player.setMute(!this.muted) }

	///@private
	onVolumeChanged:	{ this.applyVolume() }

	///@private
	onReadyChanged:		{ log("ReadyState: " + this.ready) }

	///@private
	onError: {
		this.paused = false
		this.waiting = false
		var player = this._getPlayer()

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
	onSourceChanged: {
		var player = this._getPlayer()
		if (player)
			player.setSource(value)
		if (this.autoPlay)
			this.play()
	}

	onBoxChanged: {
		this._scheduleLayout()
	}

	onRecursiveVisibleChanged: {
		var player = this._getPlayer()
		if (player)
			player.setVisibility(value)
	}

	///@private
	onCompleted: {
		volumeStorage.read()
		this.volume = volumeStorage.value ? +(volumeStorage.value) : 1.0

		var player = this._getPlayer()
		if (player)
			player.setBackgroundColor(this.backgroundColor)

		if (this.autoPlay && this.source)
			this.play()
	}
}
