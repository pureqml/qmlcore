GridView {
	id: channels;
	cellWidth: width / 3;
	cellHeight: 150;
	clip: true;
	model: channelsModel;
	delegate: ChannelDelegate {} 
}
