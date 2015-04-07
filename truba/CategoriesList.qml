ScrollableListView {
	width: 250;
	anchors.top: parent.top;
	anchors.bottom: parent.bottom;
	anchors.left: parent.left;
	clip: true;
	delegate: IconTextDelegate { width: parent.width; }

	Behavior on width { Animation { duration: 300; } }
}
