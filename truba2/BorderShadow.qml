Item {
	anchors.fill: parent;
	effects.shadow.spread: 5;
	effects.shadow.color: "#000a";
	effects.shadow.blur: 6;
	opacity: parent.activeFocus ? 1.0 : 0.0;

	Behavior on opacity { Animation { duration: 300; } }
}
