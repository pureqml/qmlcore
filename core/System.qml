Object {
	property string browser;
	property string device;
	property string vendor;
	property string os;
	property bool webkit;
	property bool portrait: renderer.width < renderer.height;
	property bool landscape: !portrait;

	onCompleted: {
		if (navigator.userAgent.indexOf('Chromium') >= 0)
			_globals.core.browser = "Chromium"
		else if (navigator.userAgent.indexOf('Chrome') >= 0)
			_globals.core.browser = "Chrome"
		else if (navigator.userAgent.indexOf('Opera') >= 0)
			_globals.core.browser = "Opera"
		else if (navigator.userAgent.indexOf('Firefox') >= 0)
			_globals.core.browser = "Firefox"
		else if (navigator.userAgent.indexOf('Safari') >= 0)
			_globals.core.browser = "Safari"
		else if (navigator.userAgent.indexOf('MSIE') >= 0)
			_globals.core.browser = "IE"
		else if (navigator.userAgent.indexOf('YaBrowser') >= 0)
			_globals.core.browser = "Yandex"

		this.browser = _globals.core.browser
		this.webkit = _globals.core.webkit
		this.device = _globals.core.device
		this.vendor = _globals.core.vendor
		this.os = _globals.core.os
	}
}
