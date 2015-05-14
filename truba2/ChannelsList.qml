GridView {
	id: channels;
	cellWidth: width / 3;
	cellHeight: 100;
	model: channelsModel;
	delegate: ChannelDelegate {} 
}
