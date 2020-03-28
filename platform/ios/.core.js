log = console.log.bind(console)

_globals.core.__deviceBackend = function() { return _globals.ios.device }
_globals.core.__videoBackends.ios = function() { return _globals.ios.video }

log("iOS detected")
exports.core.vendor = "apple"
exports.core.device = 2
exports.core.os = "ios"

exports.closeApp = function() {
	navigator.app.exitApp();
}
