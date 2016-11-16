if (navigator.userAgent.indexOf('Android') >= 0) {
	log = function(dummy) {
		var args = copyArguments(arguments)
		console.log("[QML] " + args.join(" "))
	}

	log("Android detected")
	exports.core.vendor = "google"
	exports.core.device = 2
	exports.core.os = "android"

	//exports.core.keyCodes = {
	//}

	log("Android initialized")
}
