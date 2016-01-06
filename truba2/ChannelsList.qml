Item {
	id: channelListProto;
	signal switched;
	signal channelChoosed;
	property variant currentList;
	property int count: channelsListView.count;
	property int currentIndex: channelsListView.currentIndex;
	width: renderer.width / 2.8;
	anchors.top: parent.top;
	anchors.bottom: parent.bottom;
	opacity: activeFocus ? 1.0 : 0.8;

	TrubaListView {
		id: channelsListView;
		anchors.fill: parent;
		spacing: 2;
		model: ChannelsModel { protocol: protocol; }
		delegate: ChannelDelegate { }

		onToggled: {
			updateChannelTimer.process()
			var channel = this.model.get(this.currentIndex)
			channelListProto.switched(channel)
		}

		onCurrentIndexChanged: { updateChannelTimer.restart() }
	}

	Timer {
		id: updateChannelTimer;
		interval: 800;
		repeat: false;

		process: {
			this.stop()
			channelListProto.channelChoosed(channelsListView.model.get(channelsListView.currentIndex))
		}

		onTriggered: { this.process() }
	}

	setList(list): {
		channelsListView.model.setList(list)

		channelListProto.currentList = [ ]
		for (var i = 0; i < channelsListView.count; ++i)
			channelListProto.currentList.push(channelsListView.model.get(i))
	}

	onActiveFocusChanged: {
		if (this.activeFocus)
			updateChannelTimer.restart()
	}

	resetIndex: {
		channelsListView.contentY = 0
		channelsListView.currentIndex = 0
	}

	Behavior on width { Animation { duration: 300; } }
}
