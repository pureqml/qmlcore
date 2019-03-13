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
	property real	duration;	///< content duration in seconds (only for non-live videos)
	property real	progress;	///< current playback progress in seconds
	property real	buffered;	///< how much content to buffer in seconds

	PropertyStorage { id: volumeStorage; name: "volume"; defaultValue: 1.0; }

	///@private
	constructor: {
		this.impl = null
		this._createPlayer()
	}

	///@private
	function _getPlayer() {
		if (this.impl === null)
			this._createPlayer()
		return this.impl
	}

	///@private
	function _createPlayer() {
		if (this.impl)
			return this.impl

		var source = this.source
		var preferred = this.backend
		log('preferred backend: ' + preferred)
		var backends = _globals.core.__videoBackends
		var results = []
		if (preferred && backends[preferred]) {
			var backend = backends[preferred]()
			return this.impl = backend.createPlayer(this)
		} else {
			for (var i in backends) {
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
	}

	onLoopChanged: {
		var player = this._getPlayer()
		if (player)
			player.setLoop(value)
	}

	onBackgroundColorChanged: {
		var player = this._getPlayer()
		if (player)
			player.setBackgroundColor(value)
	}

	///play video
	play: {
		if (!this.source)
			return

		log("play", this.source)
		var player = this._getPlayer()
		if (player) {
			this._scheduleLayout()
			player.play()
		}
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
		var player = this._getPlayer()
		if (player)
			player.setAutoPlay(value)

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
	stop: {
		var player = this._getPlayer()
		if (player)
			player.stop()
	}

	///pause video
	pause: {
		var player = this._getPlayer()
		if (player)
			player.pause()
	}

	///increase current volume
	volumeUp: { this.volume += 0.1 }

	///decrease current volume
	volumeDown: { this.volume -= 0.1 }

	///toggle volume mute on\off
	toggleMute: { var player = this._getPlayer(); if (player) player.setMute(!this.muted) }

	///@private
	onVolumeChanged: { this.applyVolume() }

	///@private
	onReadyChanged: { log("ReadyState: " + this.ready) }

	/**
	 * Setup DRM configuration
	 * @param {string} type - DRM type "widevine" or "playready"
	 * @param {Object} options - options for corresponded DRM type
	 * @param {function} callback - callback for async based implementation
	 * @param {function} error - callback to report fail during configuration
	 */
	setupDrm(type, options, callback, error): {
		var player = this._getPlayer()
		if (player)
			player.setupDrm(type, options, callback, error)
	}

	/**
	 * Select video track with 'trackId' id if it exists
	 * @param {string} trackId - video track ID
	 */
	setVideoTrack(trackId): {
		var player = this._getPlayer()
		if (player)
			player.setVideoTrack(trackId)
	}

	/**
	 * Select audio track with 'trackId' id if it exists
	 * @param {string} trackId - audio track ID
	 */
	setAudioTrack(trackId): {
		var player = this._getPlayer()
		if (player)
			player.setAudioTrack(trackId)
	}

	/**
	 * Return array of available video tracks
	 */
	getVideoTracks: {
		var player = this._getPlayer()
		if (player)
			return player.getVideoTracks()
		else
			return []
	}

	/**
	 * Return array of available audio tracks
	 */
	getAudioTracks: {
		var player = this._getPlayer()
		if (player)
			return player.getAudioTracks()
		else
			return []
	}

	///@private
	onError(error): {
		this.paused = false
		this.waiting = false
	}

	///@private
	onSourceChanged: {
		var player = this._getPlayer()
		if (player)
			player.setSource(value)
		if (this.autoPlay)
			this.play()
	}

	onBackendChanged: {
		this.impl = null
		this._createPlayer()
	}

	onNewBoundingBox: {
		this._scheduleLayout()
	}

	onRecursiveVisibleChanged: {
		var player = this._getPlayer()
		if (player)
			player.setVisibility(value)
	}

	///@private
	onCompleted: {
		this.volume = +(volumeStorage.value)

		var player = this._getPlayer()
		if (player)
			player.setBackgroundColor(this.backgroundColor)

		if (this.autoPlay && this.source)
			this.play()
	}
}
