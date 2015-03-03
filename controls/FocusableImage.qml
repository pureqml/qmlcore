MouseArea {
	property string focusedSource;
	property string baseSource;
	hoverEnabled: parent.recursiveVisible;
	
	signal triggered;

	Image{
		anchors.centerIn: parent;
		source: parent.baseSource;
		opacity: parent.containsMouse ? 0 : 1;

		Behavior on opacity	{ Animation { duration: 300; } }
	}

	Image{
		anchors.centerIn: parent;
		source: parent.focusedSource;
		opacity: parent.containsMouse ? 1 : 0;

		Behavior on opacity	{ Animation { duration: 300; } }
	}

	onClicked: { this.triggered(); }
}