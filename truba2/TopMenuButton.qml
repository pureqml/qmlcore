MouseArea {
	property string icon;
	width: 50;
	height: width;
	hoverEnabled: true;

	Image {
		id: settingsIcon;
		anchors.centerIn: parent;
		source: parent.icon;
	}
}

