Object {
	property string browser;
	property string device;
	property string vendor;
	property string os;

	onCompleted: {
		this.browser = _globals.core.browser
		this.device = _globals.core.device
		this.vendor = _globals.core.vendor
		this.os = _globals.core.os
	}
}
