MouseArea {
	focus: true;
	smooth: true;
	clip: true;
	property Color color: activeFocus ? colorTheme.activeBackgroundColor : colorTheme.backgroundColor;
	hoverEnabled: recursiveVisible;
	property real radius;

	Rectangle {
		anchors.fill: parent;
		color: parent.color;
		radius: parent.radius;

		Behavior on color	{ ColorAnimation { duration: 300; } }
	}

	onEntered: { 
		if (!this.activeFocus)
			this.forceActiveFocus(); 
	}

	Behavior on opacity	{ Animation { duration: 300; } }
	Behavior on height	{ Animation { duration: 300; } }
}
