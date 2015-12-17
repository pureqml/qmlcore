MouseArea {
	id: webButtonProto;
	property string icon;
	hoverEnabled: true;
	width: 50;
	height: 50;

	Image {
		source: colorTheme.res + webButtonProto.icon;
		anchors.centerIn: parent;
	}

	onCompleted: {
		if (_globals.core.vendor != "webkit")
			this.visible = false
	}
}
