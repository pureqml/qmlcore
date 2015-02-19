Button {
	id: buttonItem;
	property bool isGreen;
	opacity: activeFocus ? 1 : 0.6;
	textColor: "white";
    isGreen: activeFocus;

	gradient: Gradient {
		GradientStop { color: buttonItem.isGreen ? "#326b01" : "grey"; position: 0; }
		GradientStop { color: buttonItem.isGreen ? "#438f01" : "black"; position: 0.8; }
	}

	Behavior on height  { Animation { duration: 300; } }
	Behavior on width  { Animation { duration: 300; } }
}
