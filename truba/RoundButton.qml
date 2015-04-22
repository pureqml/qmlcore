Rectangle {
	id: roundButtonProto;
	signal toggled;
	property string icon;
	width: 76;
	height: width;
	radius: width / 2;
	color: colorTheme.backgroundColor;

	Image {
		anchors.centerIn: parent;
		source: parent.icon; 
	}

	MouseArea {
		anchors.fill: parent;

		onClicked: { roundButtonProto.toggled(); }
	}
}
