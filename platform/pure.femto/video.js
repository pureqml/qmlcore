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
				if (!ui.paused)
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
		resetState(ui);
		ui.error({ message: err })
	})

	player.on('pause', function(isPaused) {
		ui.paused = isPaused
		log('VideoPlayer: paused: ', isPaused)
	})

	player.on('timeupdate', function(position) {
		ui.waiting = false
		ui.stalled = false
		if (!ui.seeking)
			ui.progress = position;
	}.bind(ui))

	player.on('durationchange', function(duration) {
		ui.duration = duration
	}.bind(ui))


	return player
}

exports.probeUrl = function(url) {
	log('video.probeUrl', url)
	return 150
}
