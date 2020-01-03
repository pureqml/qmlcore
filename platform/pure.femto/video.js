exports.createPlayer = function(ui) {
	log('video.createPlayer')
	return new fd.VideoPlayer()
}

exports.probeUrl = function(url) {
	log('video.probeUrl', url)
	return 150
}
