ListView {
	height: 100;
	anchors.top: parent.top;
	anchors.left: parent.left;
	anchors.right: parent.right;
	orientation: ListView.Horizontal;
	delegate: IconTextDelegate { height: parent.height; }
}
