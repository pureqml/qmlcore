Button {
	id: buttonItem;
	property bool isGreen;
	opacity: activeFocus ? 1 : 0.6;
	textColor: "white";
    isGreen: activeFocus;

	gradient: Gradient {
		GradientStop { 
            color: buttonItem.isGreen ? "#326b01" : "#212121"; 
            position: 0; 
            Behavior on color   { ColorAnimation { duration: 300; } }
        }
		GradientStop { 
            color: buttonItem.isGreen ? "#438f01" : "black"; 
            position: 0.9;
            Behavior on color   { ColorAnimation { duration: 300; } }
        }
    }

	Behavior on height  { Animation { duration: 300; } }
	Behavior on width  { Animation { duration: 300; } }
}
