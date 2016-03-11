Object {
	property string browser;
	property string device;
	property string vendor;
	property string os;
	property bool webkit;
	property bool portrait: renderer.width < renderer.height;
	property bool landscape: !portrait;

	onCompleted: {
		this.browser = _globals.core.browser
		this.webkit = _globals.core.webkit
		this.device = _globals.core.device
		this.vendor = _globals.core.vendor
		this.os = _globals.core.os
	}
}
