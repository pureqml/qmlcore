 Button {
    color: activeFocus ? "#539d00" : "black";
    opacity: activeFocus ? 1 : 0.6;
    textColor: "white";

    Behavior on height  { Animation { duration: 300; } }
    Behavior on width  { Animation { duration: 300; } }
}