Item {
	property string platform;
	property string os;
	property bool portraitOrientation: false;
	property bool isWebkit: platform == "webkit";
	anchors.fill: renderer;

	updateLayout: {
		if (renderer.width < renderer.height)
			this.portraitOrientation = true
		else
			this.portraitOrientation = false
	}

	onWidthChanged: { this.updateLayout() }
	onHeightChanged: { this.updateLayout() }

	onCompleted: {
		this.platform = _globals.core.vendor
		this.updateLayout()
	}
}
