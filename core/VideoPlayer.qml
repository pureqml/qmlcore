///container item for videos
Item {
	property string backend; ///< backend to use

	signal text;		///< subtitle text appears (works now only for tizen avplay)
	signal error;		///< error occured signal
	signal finished;	///< video finished signal
	property string	source;	///< video source URL
	property string backgroundImage; ///< background image (poster) source URL
	property color	backgroundColor: "#000";	///< default background color
	property float	volume: 1.0;		///< video volume value [0:1]
	property bool	loop;		///< video loop flag
	property bool	ready;		///< read only property becomes 'true' when video is ready to play, 'false' otherwise
	property bool	muted;		///< volume mute flag
	property bool	paused;		///< video paused flag
	property bool	waiting;	///< wating flag while video is seeking and not ready to continue playing
	property bool	seeking;	///< seeking flag
	property bool	stalled;	///< playback stalled
	property bool	autoPlay;	///< play video immediately after source changed
	property real	duration;	///< content duration in seconds (only for non-live videos)
	property real	progress;	///< current playback progress in seconds
	property real	buffered;	///< how much content to buffer in seconds
	property real	startPosition;	///< second at which the video should start playback

	///@private
	constructor: {
		this.impl = null
		this._createPlayer()

		//see explanations in BaseView.onHighlightChanged:
		var p = parent
		var handler = this._scheduleLayout.bind(this)
		while(p) {
			this.connectOn(p, 'scrollEvent', handler)
			p = p.parent
		}
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
		var backends = $core.__videoBackends
		var results = []
		if (preferred && backends[preferred]) {
			var backend = backends[preferred]()
			this.impl = backend.createPlayer(this)
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
			this.impl = results[0].backend.createPlayer(this)
		}
		if (this.source)
			this.impl.setSource(this.source)
		return this.impl
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

	/**
	 * Set custom option in video player
	 * @param {string} name - option name
	 * @param {any} value - option value
	 */
	setOption(name, value): {
		var player = this._getPlayer()
		if (player)
			player.setOption(name, value)
	}

	///@private
	applyVolume: {
		if (this.volume > 1.0)
			this.volume = 1.0;
		else if (this.volume < 0.0)
			this.volume = 0.0;

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
			player.setRect.apply(player, this.toScreen().slice(0, 4))
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

	///@private
	onVolumeChanged: { this.applyVolume() }

	onAutoPlayChanged: { this.setOption('autoplay', value) }

	///@private
	onReadyChanged: { log("ReadyState: " + this.ready) }

	///@private
	onMutedChanged: {
		var player = this._getPlayer()
		if (player)
			player.setMute(this.muted)
	}

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
	 * Select subtitles with 'trackId' id if it exists
	 * @param {string} trackId - subtitles track ID
	 */
	setSubtitles(trackId): {
		var player = this._getPlayer()
		if (player)
			player.setSubtitles(trackId)
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

	/**
	 * Return array of available subtitles
	 */
	getSubtitles: {
		var player = this._getPlayer()
		if (player)
			return player.getSubtitles()
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
		if (player) {
			log('setting source to', value)
			player.setSource(value)
			this.__autoPlay()
		} else
			log('WARNING: skipping VideoPlayer.setSource')
	}

	onBackgroundImageChanged: { this.setOption('poster', value) }

	onBackendChanged: {
		log('backend changed to', value)
		if (this.impl) {
			log('disposing old player...')
			try {
				this.impl.dispose()
			} catch(ex) {
				log('player.dispose failed', ex)
			}
			this.impl = null
		}
		this._createPlayer()
	}

	onNewBoundingBox: {
		this._scheduleLayout()
	}

	onRecursiveVisibleChanged: {
		var player = this._getPlayer()
		if (value)
			this._scheduleLayout()
		if (player)
			player.setVisibility(value)
	}

	function __autoPlay() {
		if (this.autoPlay && this.source)
			this.play()
	}

	onCompleted: {
		this._scheduleLayout()
		var player = this._getPlayer()
		if (player)
			player.setBackgroundColor(this.backgroundColor)
		this.__autoPlay()
	}
}
