Image {
	property string focusedSource;
	property string baseSource;
	
	signal triggered;

	source: imageMouseArea.containsMouse ? baseSource : focusedSource;

	MouseArea {
		id: imageMouseArea;
		anchors.centerIn: parent;
		anchors.margins: -5;
		hoverEnabled: parent.recursiveVisible;

		onClicked: { this.parent.triggered(); }
		onEntered: {
			console.log("imageMouseArea onEntered")
		}
	}
}