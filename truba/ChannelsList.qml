GridView {
	id: channelListProto;
	height: cellHeight * 3;
	width: cellWidth * 4;
	cellHeight: renderer.height / 5;
	cellWidth: renderer.width / 6.5;
	flow: GridView.FlowTopToBottom;
	orientation: ListView.Horizontal;
	delegate: ChannelDelegate { height: parent.cellHeight; }

	ListModel { id: indecatorInnerModel; }

	ListView {
		id: indicator;
		height: 10;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.bottom: parent.top;
		anchors.leftMargin: 20;
		spacing: 10;
		visiible: count > 1;
		orientation: ListView.Horizontal;
		model: indecatorInnerModel;
		delegate: Rectangle {
			height: parent.height;
			width: height;
			radius: width / 2;
			color: "#fff";
			opacity: model.selected ? 1.0 : 0.5;
		}

		select(idx): {
			if (!this.model)
				return;

			for (var i = 0; i < this.count; ++i)
				this.model.set(i, {selected: i == idx});
		}

		reset: {
			indecatorInnerModel.clear();

			var count = channelListProto.contentWidth / channelListProto.width;
			for (var i = 0; i < count; ++i)
				indecatorInnerModel.append({ selected: false });

			if (count)
				this.select(0);
		}

		updateIdx: { this.select(Math.round(channelListProto.contentX / channelListProto.width)); }
		onClicked: { channelListProto.contentX = this.currentIndex * channelListProto.width; }
	}

	onContentXChanged:		{ indicator.updateIdx(); }
	onContentWidthChanged:	{ indicator.reset(); }
}
