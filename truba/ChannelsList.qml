GridView {
	height: cellHeight * 3;
	width: cellWidth * 5;
	cellHeight: 140;
	cellWidth: 200;
	flow: GridView.FlowTopToBottom;
	orientation: ListView.Horizontal;
	delegate: ChannelDelegate { height: parent.cellHeight; }
}
