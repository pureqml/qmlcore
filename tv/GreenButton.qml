Button {
	id: buttonItem;

	gradient: Gradient {
		GradientStop { color: buttonItem.activeFocus ? "#539d00" : "grey"; position: 0; }
		GradientStop { color: buttonItem.activeFocus ? "#539d00" : "black"; position: 0.8; }
	}

	opacity: activeFocus ? 1 : 0.6;
	textColor: "white";

	Behavior on height  { Animation { duration: 300; } }
	Behavior on width  { Animation { duration: 300; } }
}
