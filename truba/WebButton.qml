MouseArea {
	id: webButtonProto;
	property string icon;
	property int size: 50;
	hoverEnabled: true;
	width: size;
	height: size;
	visible: globals.isWebkit;

	Image {
		source: colorTheme.res + "controls/" + webButtonProto.icon;
		anchors.fill: parent;
	}
}
