Object {
	property string userAgent;
	property string language;
	property string browser;
	property string vendor;
	property string os;
	property bool webkit;
	property bool support3dTransforms;
	property bool supportTransforms;
	property bool supportTransitions;
	property bool portrait: parent.width < parent.height;
	property bool landscape: !portrait;
	property bool pageActive: true;
	property int contextWidth: parent.width;
	property int contextHeight: parent.height;
	property enum device { Desktop, Tv, Mobile };
	property enum layoutType { MobileS, MobileM, MobileL, Tablet, Laptop, LaptopL, Laptop4K };

	onContextWidthChanged: { this._updateLayoutType() }
	onContextHeightChanged: { this._updateLayoutType() }

	_updateLayoutType: {
		if (!this.contextWidth || !this.contextHeight)
			return
		var min = this.contextWidth;// < this.contextHeight ? this.contextWidth : this.contextHeight

		if (min <= 320)
			this.layoutType = this.MobileS
		else if (min <= 375)
			this.layoutType = this.MobileM
		else if (min <= 425)
			this.layoutType = this.MobileL
		else if (min <= 768)
			this.layoutType = this.Tablet
		else if (this.contextWidth <= 1024)
			this.layoutType = this.Laptop
		else if (this.contextWidth <= 1440)
			this.layoutType = this.LaptopL
		else
			this.layoutType = this.Laptop4K
	}

	constructor: {
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
		this._context.language = this.language.split('-')[0]
		this.support3dTransforms = window.Modernizr && window.Modernizr.csstransforms3d
		this.supportTransforms = window.Modernizr && window.Modernizr.csstransforms
		this.supportTransitions = window.Modernizr && window.Modernizr.csstransitions

		var self = this
		window.onfocus = function() { self.pageActive = true }
		window.onblur = function() { self.pageActive = false }
	}
}
