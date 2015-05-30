GridView {
	id: channels;
	signal detailsRequest;
	property int collCount: width / cellWidth;
	property int hoveredIndex: 0;
	cellWidth: width / 3;
	cellHeight: 150;
	clip: true;
	model: channelsModel;
	hoverEnabled: true;
	delegate: ChannelDelegate {} 

	getCurrentDelegateX: { return this.currentIndex % this.collCount * this.cellWidth; }
	getCurrentDelegateY: { return (Math.floor((this.currentIndex) / this.collCount) + 1) * this.cellHeight - this.contentY; }
}
