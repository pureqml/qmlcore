Rectangle {
	id: roundButtonProto;
	signal toggled;
	property string icon;
	property bool containsMouse: roundButtonInnerArea.containsMouse;
	width: 76;
	height: width;
	radius: width / 2;
	color: colorTheme.backgroundColor;

	Image {
		anchors.centerIn: parent;
		source: parent.icon; 
	}

	MouseArea {
		id: roundButtonInnerArea;
		anchors.fill: parent;
		hoverEnabled: true;

		onClicked: { roundButtonProto.toggled(); }
	}
}
