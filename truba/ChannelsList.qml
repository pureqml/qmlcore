GridView {
	height: parent.height;
	width: cellWidth * 5;
	cellHeight: 140;
	cellWidth: 200;
	orientation: ListView.Horizontal;
	delegate: ChannelDelegate { height: parent.cellHeight; }
}
