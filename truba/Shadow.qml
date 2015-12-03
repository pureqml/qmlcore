Rectangle {
	property bool active: false;
	property bool leftToRight: true;
	opacity: active ? 1.0 : 0.0;
	width: 30;
	gradient: Gradient {
		orientation: 1;

		GradientStop { color: parent.parent.leftToRight ? "#0006" : "#0000"; position: 0; }
		GradientStop { color: parent.parent.leftToRight ? "#0000" : "#0006"; position: 1; }
	}

	Behavior on opacity { Animation { duration: 300; } }
}
