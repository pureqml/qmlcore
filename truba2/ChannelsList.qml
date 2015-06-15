GridView {
	id: channels;
	signal detailsRequest;
	signal channelSelected;
	property int collCount: width / cellWidth;
	property int hoveredIndex: 0;
	property bool mouseLeaved: false;
	cellWidth: width / 3;
	cellHeight: 150;
	clip: true;
	model: channelsModel;
	hoverEnabled: true;
	contentFollowsCurrentItem: false;
	delegate: ChannelDelegate {} 

	onClicked: {
		if (!this.mouseLeaved)
			this.channelSelected();
	}

	onPressedChanged: {
		if (this.pressed)
			this.mouseLeaved = false;
	}

	getCurrentDelegateX: { return this.currentIndex % this.collCount * this.cellWidth; }
	getCurrentDelegateY: { return (Math.floor((this.currentIndex) / this.collCount) + 1) * this.cellHeight - this.contentY; }
}
