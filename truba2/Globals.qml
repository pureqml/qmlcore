Object {
	property string platform;
	property bool isHtml5: platform == "webkit";

	onCompleted: { this.platform = _globals.core.vendor }
}
