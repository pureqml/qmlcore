Object {
	property string webkitVersion;
	property string userAgent;
	property string language;
	property string browser;
	property string device;
	property string vendor;
	property string os;
	property bool webkit;
	property bool has3d;
	property bool hasCssTransforms;
	property bool hasCssTransitions;
	property bool portrait: context.width < context.height;
	property bool landscape: !portrait;

	onCompleted: {
		var browser = ""
		if (navigator.userAgent.indexOf('Chromium') >= 0)
			browser = "Chromium"
		else if (navigator.userAgent.indexOf('Chrome') >= 0)
			browser = "Chrome"
		else if (navigator.userAgent.indexOf('Opera') >= 0)
			browser = "Opera"
		else if (navigator.userAgent.indexOf('Firefox') >= 0)
			browser = "Firefox"
		else if (navigator.userAgent.indexOf('Safari') >= 0)
			browser = "Safari"
		else if (navigator.userAgent.indexOf('MSIE') >= 0)
			browser = "IE"
		else if (navigator.userAgent.indexOf('YaBrowser') >= 0)
			browser = "Yandex"

		this.browser = browser
		this.userAgent = navigator.userAgent
		this.webkit = navigator.userAgent.toLowerCase().indexOf('webkit') >= 0
		this.device = _globals.core.device
		this.vendor = _globals.core.vendor
		this.os = _globals.core.os
		this.language = navigator.language
		this.has3d = window.Modernizr && window.Modernizr.csstransforms3d
		this.hasCssTransitions = window.Modernizr && window.Modernizr.csstransitions
		this.hasCssTransforms = window.Modernizr && window.Modernizr.csstransforms

		var result = /WebKit\/([\d.]+)/.exec(navigator.userAgent);
		if (result && result.length > 1)
			this.webkitVersion = result[1]
	}
}
