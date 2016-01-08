Item {
	id: channelListProto;
	signal switched;
	signal channelChoosed;
	signal epgCalled;
	property variant currentList;
	property int count: channelsListView.count;
	property int currentIndex: channelsListView.currentIndex;
	property bool showed: false;
	width: renderer.width / 2.8;
	anchors.top: parent.top;
	anchors.bottom: parent.bottom;
	opacity: showed ? (activeFocus ? 1.0 : 0.8) : 0.0;

	TrubaListView {
		id: channelsListView;
		anchors.fill: parent;
		spacing: 2;
		model: ChannelsModel { protocol: protocol; }
		delegate: ChannelDelegate {
			onEpgCalled: {
				if (channelsListView.model.get(channelsListView.currentIndex).program.startTime)
					channelListProto.epgCalled()
			}
		}

		onToggled: { channelListProto.switched(this.model.get(this.currentIndex)) }
		onCurrentIndexChanged: { channelListProto.channelChoosed(this.model.get(this.currentIndex)) }

		onRightPressed: {
			if (this.model.get(this.currentIndex).program.startTime)
				channelListProto.epgCalled()
		}
	}

	setList(list): {
		channelsListView.model.setList(list)

		channelListProto.currentList = [ ]
		for (var i = 0; i < channelsListView.count; ++i)
			channelListProto.currentList.push(channelsListView.model.get(i))

		this.show()
	}

	hide: {
		this.resetIndex()
		this.showed = false
	}

	show: { this.showed = true }

	resetIndex: {
		channelsListView.contentY = 0
		channelsListView.currentIndex = 0
	}

	Behavior on width { Animation { duration: 300; } }
}
