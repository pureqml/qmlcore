MouseArea {
	id: webButtonProto;
	property string icon;
	hoverEnabled: true;
	width: 50;
	height: 50;
	visible: globals.isHtml5;

	Image {
		source: colorTheme.res + webButtonProto.icon;
		anchors.centerIn: parent;
	}
}
