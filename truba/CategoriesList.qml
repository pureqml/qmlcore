ListView {
	width: activeFocus ? 300 : 50;
	anchors.top: parent.top;
	anchors.left: parent.left;
	anchors.bottom: parent.bottom;
	clip: true;
	delegate: IconTextDelegate { }

	Behavior on width { Animation { duration: 300; } }
}
