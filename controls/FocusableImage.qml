Image {
	property string focusedSource;
	property string baseSource;
	
	signal triggered;

	source: imageMouseArea.containsMouse ? focusedSource : baseSource;
	opacity: imageMouseArea.containsMouse ? 1 : 0.5;

	MouseArea {
		id: imageMouseArea;
		anchors.fill: parent;
		anchors.margins: -5;
		hoverEnabled: parent.recursiveVisible;

		onClicked: { this.parent.triggered(); }
		onEntered: {
			console.log("imageMouseArea onEntered")
		}
	}
}