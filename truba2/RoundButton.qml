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
		anchors.fill: parent;
		anchors.margins: parent.width / 4;
		fillMode: Image.PreserveAspectFit;
		source: parent.icon; 
	}

	MouseArea {
		id: roundButtonInnerArea;
		anchors.fill: parent;
		hoverEnabled: true;

		onClicked: { roundButtonProto.toggled(); }
	}
}
