var Player = function(ui) {
	var player = ui._context.createElement('div')

	player.dom.id = "yt-player"
	this.element = player
	this.ui = ui

	ui.element = player
	ui.parent.element.append(ui.element)

	var tag = document.createElement('script')
	tag.src = "https://www.youtube.com/iframe_api"
	tag.async = false
	var self = this
	this.iframeIsReady = false
	tag.onload = ui._context.wrapNativeCallback(function(res) {
		self.youTubeIframeAPIReady()
	})

	var firstScriptTag = document.getElementsByTagName('script')[0]
	firstScriptTag.parentNode.insertBefore(tag, firstScriptTag)
}

Player.prototype.playerReady = function(event) {
	this.playerController = event.target
	this.ui.ready = true
	this.ui.waiting = true
}

Player.prototype.playerStateChange = function(event) {
	log("playerStateChange", event)
	switch (event.data) {
		case YT.PlayerState.PLAYING:
			this.ui.duration = event.target.getDuration()
			this.ui.waiting = false
			this.ui.paused = false
			break
		case YT.PlayerState.PAUSED:
			this.ui.paused = true
			break
	}
}

Player.prototype.setupPlayer = function() {
	log("setupPlayer", this.source, "iframeIsReady", this.iframeIsReady)
	if (!this.source || !this.iframeIsReady)
		return

	var ui = this.ui
	this.player
	var self = this
	YT.ready(function() {
		self.player = new YT.Player("yt-player", {
			width: ui.width,
			height: ui.height,
			videoId: this.source,
			playerVars: {
				end: 0, autoplay: ui.autoPlay, loop: 0, controls: 0, showinfo: 0, modestbranding: 1, fs: 0, cc_load_policty: 0, iv_load_policy: 3, autohide: 0
			},
			events: {
				onReady: ui._context.wrapNativeCallback(self.playerReady).bind(self),
				onStateChange: ui._context.wrapNativeCallback(self.playerStateChange).bind(self)
			}
		});
	})
}

Player.prototype.youTubeIframeAPIReady = function() {
	this.iframeIsReady = true
	this.setupPlayer()
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

Player.prototype.setSource = function(url) {
	this.ui.ready = false
	this.source = url
	this.setupPlayer()
}

Player.prototype.play = function() {
	if (!this.playerController)
		return
	this.playerController.playVideo();
}

Player.prototype.pause = function() {
	this.playerController.pauseVideo();
}

Player.prototype.stop = function() {
	this.playerController.pauseVideo();
}

Player.prototype.seek = function(delta) {
}

Player.prototype.seekTo = function(tp) {
}

Player.prototype.setVolume = function(volume) {
}

Player.prototype.setMute = function(muted) {
}

Player.prototype.setLoop = function(loop) {
}

Player.prototype.setOption = function(name, value) {
}

Player.prototype.setRect = function(l, t, r, b) {
	//not needed in this port
}

Player.prototype.setVisibility = function(visible) {
}

Player.prototype.setupDrm = function(type, options, callback, error) {
	log('Not implemented')
}

Player.prototype.getSubtitles = function() {
	return []
}

Player.prototype.getVideoTracks = function() {
	return []
}

Player.prototype.getAudioTracks = function() {
	return []
}

Player.prototype.setAudioTrack = function(trackId) {
}

Player.prototype.setVideoTrack = function(trackId) {
}

Player.prototype.setVideoTrack = function(trackId) {
}

Player.prototype.setBackgroundColor = function(color) {
}

exports.createPlayer = function(ui) {
	return new Player(ui)
}

exports.probeUrl = function(url) {
	return 10
}

exports.Player = Player
