GridView {
	height: parent.height;
	cellWidth: 130;
	cellHeight: cellWidth;
	anchors.fill: parent;
	orientation: ListView.Horizontal;
	delegate: ChannelDelegate { height: parent.cellHeight; }
}
