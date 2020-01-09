exports.createPlayer = function(ui) {
	log('video.createPlayer')

	var player = new fd.VideoPlayer()

	var resetState = function() {
		ui.ready = false
		ui.paused = false
		ui.waiting = false
		ui.seeking = false
		ui.stalled = false
	}

	player.on('stateChanged', function(state) {
		log('VideoPlayer: stateChanged ' + state)
		switch(state) {
			case 1:
				log("VideoPlayer: STATE_IDLE")
				resetState()
				break;
			case 2:
				log("VideoPlayer: STATE_BUFFERING")
				ui.waiting = true
				break;
			case 3:
				log("VideoPlayer: STATE_READY")
				ui.waiting = false
				ui.ready = true
				break;
			case 4:
				log("VideoPlayer: STATE_ENDED")
				ui.finished()
				resetState()
				break;
			default:
				log("VideoPlayer: unhandled state", typeof state, state)
		}
	})

	player.on('seeked', function() {
		ui.waiting = false
		ui.seeking = false
	})

	player.on('error', function(err) {
		log('VideoPlayer: error: ', err)
		ui.error()
	})

	return player
}

exports.probeUrl = function(url) {
	log('video.probeUrl', url)
	return 150
}
