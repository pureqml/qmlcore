exports.core.device = 0
var userAgent = exports.core.userAgent.toLowerCase()
if (userAgent.indexOf("linux")) {
	exports.core.os = "Linux"
} else if (userAgent.indexOf("windows")) {
	exports.core.os = "Windows"
} else if (userAgent.indexOf("mac")) {
	exports.core.os = "MacOS"
	exports.core.vendor = "Apple"
} else {
	exports.core.os = "electronjs"
}

_globals.core.__deviceBackend = function() { return _globals.electronjs.device }
