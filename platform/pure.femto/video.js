var Player = function(ui) {
	this.ui = ui
}

Player.prototype.setupDrm = function(type, options, callback, error) {
	log("Player.SetupDRM", type, options)
}

Player.prototype.stop = function() {
	log("Player.stop")
}

Player.prototype.setSource = function(url) {
	log("Player.setSource", url)
}

Player.prototype.setLoop = function(loop) {
	log("Player.setLoop", loop)
}

Player.prototype.setBackgroundColor = function(color) {
	log("Player.setBackground", color)
}

Player.prototype.play = function() {
	log("Player.play")
}

Player.prototype.seek = function(pos) {
	log("Player.seek", pos)
}

Player.prototype.seekTo = function(pos) {
	log("Player.seekTo", pos)
}

Player.prototype.setOption = function(name, value) {
	log("Player.setOption", name, value)
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

exports.createPlayer = function(ui) {
	log('video.createPlayer')
	return new Player(ui)
}

exports.probeUrl = function(url) {
	log('video.probeUrl', url)
	return 150
}

exports.Player = Player
