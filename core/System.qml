Object {
	property string userAgent;
	property string language;
	property string browser;
	property string device;
	property string vendor;
	property string os;
	property bool webkit;
	property bool has3d;
	property bool portrait: context.width < context.height;
	property bool landscape: !portrait;

	_has3d: {
		// More: https://gist.github.com/lorenzopolidori/3794226
		if (!window.getComputedStyle)
			return false;

		var el = document.createElement('p'),
			has3d,
			transforms = {
				'webkitTransform':'-webkit-transform',
				'OTransform':'-o-transform',
				'msTransform':'-ms-transform',
				'MozTransform':'-moz-transform',
				'transform':'transform'
			};

		document.body.insertBefore(el, null);
		for (var t in transforms) {
			if (el.style[t] !== undefined) {
				el.style[t] = 'translate3d(1px,1px,1px)';
				has3d = window.getComputedStyle(el).getPropertyValue(transforms[t]);
			}
		}

		document.body.removeChild(el);
		return (has3d !== undefined && has3d.length > 0 && has3d !== "none");
	}

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
		this.has3d = this._has3d()
	}
}
