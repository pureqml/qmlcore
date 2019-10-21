var logPanelFlag = window["$manifest$logPanel"]
var logMessagesBuffer = []

if (logPanelFlag) {
	log = function(dummy) {
		var args = Array.prototype.slice.call(arguments)
		var logger = document.getElementById("logger") || undefined
		if (logger) {
			if (logMessagesBuffer.length > 0) {
				for (var i = 0; i < logMessagesBuffer.length; ++i)
					logger.innerHTML += logMessagesBuffer[i] + "<br>"
				logMessagesBuffer = []
			}
			logger.innerHTML += args.join(" ") + "<br>"
		} else {
			logMessagesBuffer.push(args.join(" "))
		}
	}
} else {
	log = console.log.bind(console)
}
