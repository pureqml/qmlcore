GridView {
	height: parent.height;
	flow: GridView.FlowTopToBottom;
	cellWidth: 130;
	cellHeight: cellWidth;
	anchors.fill: parent;
	anchors.rightMargin: cellWidth;
	orientation: ListView.Horizontal;
	delegate: ChannelDelegate { height: parent.cellHeight; }
}
