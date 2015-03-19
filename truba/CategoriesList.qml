ListView {
	height: 50;
	anchors.top: parent.top;
	anchors.left: parent.left;
	anchors.right: parent.right;
	orientation: ListView.Horizontal;
	clip: true;
	delegate: IconTextDelegate { }

	Behavior on width { Animation { duration: 300; } }
}
