ListView {
	height: 130;
	anchors.top: parent.top;
	anchors.left: parent.left;
	anchors.right: parent.right;
	orientation: ListView.Horizontal;
	delegate: ChannelDelegate { }
}
