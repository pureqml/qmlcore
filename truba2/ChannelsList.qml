GridView {
	id: channels;
	cellWidth: width / 3;
	cellHeight: 150;
	model: channelsModel;
	delegate: ChannelDelegate {} 
}
