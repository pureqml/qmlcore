Object {
	property string userAgent;
	property string language;
	property string browser;
	property string device;
	property string vendor;
	property string os;
	property bool webkit;
	property bool support3dTransforms;
	property bool supportTransforms;
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
		this.support3dTransforms = window.Modernizr && window.Modernizr.csstransforms3d
		this.supportTransforms = window.Modernizr && window.Modernizr.csstransforms
	}
}
