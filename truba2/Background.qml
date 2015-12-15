Rectangle {
	anchors.fill: parent;
	color: colorTheme.focusablePanelColor;
	opacity: parent.activeFocus ? 1.0 : 0.8;

	Behavior on opacity { Animation { duration: 300; } }
}
