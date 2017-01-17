exports.core.os = navigator.platform
exports.core.userAgent = navigator.userAgent
exports.core.language = navigator.language

var _checkDevice = function(target, info) {
	if (navigator.userAgent.indexOf(target) < 0)
		return

	exports.core.vendor = info.vendor
	exports.core.device = info.device
	exports.core.os = info.os
}

if (!exports.core.vendor) {
	_checkDevice('Blackberry', { 'vendor': 'blackberry', 'device': 2, 'os': 'blackberry' })
	_checkDevice('Android', { 'vendor': 'google', 'device': 2, 'os': 'android' })
	_checkDevice('iPhone', { 'vendor': 'apple', 'device': 2, 'os': 'iOS' })
	_checkDevice('iPad', { 'vendor': 'apple', 'device': 2, 'os': 'iOS' })
	_checkDevice('iPod', { 'vendor': 'apple', 'device': 2, 'os': 'iOS' })
}

if (navigator.userAgent.indexOf('Chromium') >= 0)
	exports.core.browser = "Chromium"
else if (navigator.userAgent.indexOf('Chrome') >= 0)
	exports.core.browser = "Chrome"
else if (navigator.userAgent.indexOf('Opera') >= 0)
	exports.core.browser = "Opera"
else if (navigator.userAgent.indexOf('Firefox') >= 0)
	exports.core.browser = "Firefox"
else if (navigator.userAgent.indexOf('Safari') >= 0)
	exports.core.browser = "Safari"
else if (navigator.userAgent.indexOf('MSIE') >= 0)
	exports.core.browser = "IE"
else if (navigator.userAgent.indexOf('YaBrowser') >= 0)
	exports.core.browser = "Yandex"
else
	exports.core.browser = ''


_globals._backend = function() { return _globals.html5.html }
