MouseArea {
	focus: true;
	smooth: true;
	clip: true;
	property Color color: (activeFocus && !focusOnHover) || containsMouse ? colorTheme.activeBackgroundColor : colorTheme.backgroundColor;
	hoverEnabled: recursiveVisible;
	property real radius;
	property bool focusOnHover: false;

	Rectangle {
		anchors.fill: parent;
		color: parent.color;
		radius: parent.radius;
		border.width: 1;
		border.color: "#75757575";
		anchors.margins: 1;
	}

	onEntered: { 
		if (!this.activeFocus)
			this.forceActiveFocus(); 
	}

	Behavior on opacity	{ Animation { duration: 250; } }
	Behavior on color { ColorAnimation { duration: 300; } }
}
